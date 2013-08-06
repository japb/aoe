#include <unistd.h>

int main() {
	char *filename = "/bin/sh";
	char *envp[1] = {0};
	char *argv[2] = {filename, 0};	

	execve(filename, argv, envp);
}
