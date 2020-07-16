int 
strncmp(const char *s1, const char *s2, size_t n)
{
	if (!s1 || !s2)
		return (0);

	while (n && (*s1 == *s2)) {
		if (*s1 == 0)
			return (0);
		s1++;
		s2++;
		n--;
	}
	if (n)
		return (*s1 - *s2);
	return (0);
}
