from typing import Text, List, Dict, Iterator

import sys
import click

from dataclasses import dataclass
from xml.etree import ElementTree

TFilePath = click.Path(exists=True, file_okay=True, dir_okay=False, readable=True)

@dataclass
class Block:
    title: Text
    lines: List[Text]

@dataclass
class StructMember:
    name: Text
    type_ref: Text

@dataclass
class Struct:
    name: Text
    members: List[StructMember]

@dataclass
class PackedArray:
    idx: Text
    hi: Text
    lo: Text
    type_ref: Text

@dataclass
class Variable:
    name: Text
    type_ref: Text

@dataclass
class Port:
    name: Text
    type_ref: Text
    direction: Text

@dataclass
class Instance:
    name: Text
    modname: Text

@dataclass
class Module:
    name: Text
    ports: List[Port]
    variables: List[Variable]
    instances: List[Instance]

@dataclass
class Reference:
    type_name: Text
    reference: Text

def warn(message):
    sys.stderr.write(f'(warn) {message}\n')

def print_document(doc: List[Block]):
    for block in doc:
        print(f'# {block.title}')
        for line in block.lines:
            print(line)
        print('')  # empty line

# Python 3.9
def removeprefix(s: Text, prefix: Text) -> Text:
    if s.startswith(prefix):
        return s[len(prefix):]
    else:
        return s[:]

def parse_hex(s: Text) -> int:
    if s.startswith('32\'h'):
        return int(s[4:], base=16)
    elif s.startswith('32\'sh'):
        return int(s[5:], base=16)
    else:
        raise ValueError(s)


@click.group()
def cli():
    pass

@cli.command(short_help='Dump the ports description file.')
@click.argument('path', type=TFilePath)
def dump(path: Text):
    tree = ElementTree.parse(path)
    root = tree.getroot()

    avail = Block('available', [])
    doc: List[Block] = [
        Block('ports', []),
        avail
    ]

    # pass 1: dump type list
    type_table = root.find('netlist/typetable')
    assert type_table is not None

    type_mp: Dict[Text, Text] = {}
    structs: List[Struct] = []
    arrays: List[PackedArray] = []
    for t in type_table:
        idx = t.get('id')
        assert idx is not None

        if t.tag == 'basicdtype':
            name = t.get('name')
            left = t.get('left', default='0')
            right = t.get('right', default='0')
            assert name is not None
            type_mp[idx] = name if left == right else f'{name}[{left}:{right}]'
        elif t.tag == 'refdtype' or t.tag == 'paramtypedtype':
            name = t.get('name')
            assert name is not None
            type_mp[idx] = name
        elif t.tag == 'uniondtype':
            name = t.get('name', default=f'__union_{idx}')
            assert name is not None
            name = removeprefix(name, '$unit::')
            type_mp[idx] = name

            struct = Struct(f'union:{name}', [
                StructMember(
                    v.get('name', default='*'),
                    v.get('sub_dtype_id', default='*')
                )
                for v in t
                if v.tag == 'memberdtype'
            ])
            structs.append(struct)
        elif t.tag == 'structdtype':
            name = t.get('name', default=f'__struct_{idx}')
            assert name is not None
            name = removeprefix(name, '$unit::')
            type_mp[idx] = name

            struct = Struct(f'struct:{name}', [
                StructMember(
                    v.get('name', default='*'),
                    v.get('sub_dtype_id', default='*')
                )
                for v in t
                if v.tag == 'memberdtype'
            ])
            structs.append(struct)
        elif t.tag == 'packarraydtype':
            type_mp[idx] = ''  # to be filled
            type_ref = t.get('sub_dtype_id')
            assert type_ref is not None
            hi, lo = list(map(
                lambda x: str(parse_hex(str(x.get('name')))),
                t.findall('range/const')
            ))

            arrays.append(PackedArray(idx, hi, lo, type_ref))
        elif t.tag == 'enumdtype':
            name = t.get('name', default=f'__enum_{idx}')
            assert name is not None
            type_mp[idx] = name
        else:
            warn(f'Unsupported type: "{t.tag}"')

    # pass 2: review packed arrays, dump structs/unions
    for array in arrays:
        type_name = type_mp[array.type_ref]
        type_mp[array.idx] = f'{type_name}[{array.hi}:{array.lo}]'

    for struct in structs:
        blk = Block(struct.name, [
            f'{type_mp[member.type_ref]} {member.name}'
            for member in struct.members
        ])
        doc.append(blk)

    # pass 3: dump modules
    netlist = root.find('netlist')
    assert netlist is not None

    top = None
    module_mp: Dict[Text, Module] = {}
    for t in netlist:
        if t.tag != 'module':
            continue

        name = t.get('name')
        is_top = t.get('topModule')
        assert name is not None
        if is_top == '1':
            top = name

        m = Module(name, [], [], [])

        for u in t:
            if u.tag == 'var':
                vname = u.get('name')
                type_ref = u.get('dtype_id')
                assert vname is not None
                assert type_ref is not None

                direction = u.get('dir')
                if direction is not None:
                    m.ports.append(Port(
                        vname, type_ref, direction
                    ))
                else:
                    m.variables.append(Variable(
                        vname, type_ref
                    ))
            elif u.tag == 'instance':
                iname = u.get('name')
                modname = u.get('defName')
                assert iname is not None
                assert modname is not None

                m.instances.append(Instance(
                    iname, modname
                ))

        module_mp[name] = m

    # pass 4: generate references
    def dfs(m: Module, prefix: Text) -> Iterator[Reference]:
        for port in m.ports:
            type_name = type_mp[port.type_ref]
            yield Reference(type_name, f'{prefix}{port.name}')
        for variable in m.variables:
            type_name = type_mp[variable.type_ref]
            yield Reference(type_name, f'{prefix}{variable.name}')

        for instance in m.instances:
            submodule = module_mp[instance.modname]
            yield from dfs(submodule, f'{prefix}{instance.name}.')

    top_module = next(iter(module_mp.values())) if top is None else module_mp[top]
    for ref in sorted(dfs(top_module, ''), key=lambda x: x.reference):
        avail.lines.append(f'{ref.type_name} {ref.reference}')

    print_document(doc)


@cli.command(short_help='Generate top module.')
def parse():
    ...


if __name__ == '__main__':
    cli()