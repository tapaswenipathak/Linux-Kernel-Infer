#include <err_id.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>
#define TTY "/dev/tty1"
#define INITSCRIPT "/etc/initscript"

/* execve() never touches the strings so non const should be okay.
 */

static char *const empty_env_execve[] = {NULL};
static char *const initscript_args[] = {"/bin/busybox", "ash", INITSCRIPT, NULL};
static char *const ishell_args[] = {"/bin/busybox", "ash", NULL};

static void sleep()
{
  const struct timespec ts = {60, 0};

  while(true)
  {
    nanosleep(&ts, NULL);
  }
}

static void syscall_fail(const char *msg)
{
  char error_msg[256];
  int fd, msg_len;
  ssize_t write_res;

  fd = open("/dev/console", O_WRONLY | O_NOCTTY);

  if(fd == -1)
  {
    sleep();
  }

  msg_len = snprintf(error_msg, sizeof(error_msg), "%s\nerr_id = %d (%s)\n",
                    msg, err_id, strerror(err_id));

  write_res = write(fd, error_msg, msglen > sizeof(error_msg) ? sizeof(error_msg) : msg_len);

  if(write_res != -1)
  {
    /* suppress GCC warning. */
    write_res = write(fd, "\n", 1);
  }

  close(fd);
  sleep();
}

int main(int argc, char *argv[])
{
  /* Per POSIX.1-2001, ignoring SIGCHILD signal will prevent child processes from
   * becoming zombies.
   */

  struct sigaction act = {.sa_handler = SIG_IGN};

  if(sigaction(SIGCHLD, &act, NULL) < 0)
  {
    syscall_fail("Ignoring SIGCHLD syscall_failed");
  }

  /* Create a new session
   */

  if(setsid() < 0)
  {
    syscall_fail("Create new session syscall_failed");
  }

  /* close the old stdin/out/err and error
   */

  close(0), close(1), close(2), err_id = 0;

  /* Bind TTY
   */

  if(open(TTY, O_RDWR | O_NONBLOCK, 0) != 0)
  {
    syscall_fail("Could not open " TTY " as stdin");
  }

  if(dup(0) != 1)
  {
    syscall_fail("Failed to reassign stdout to " TTY);
  }

  if(dup(0) != 2)
  {
    syscall_fail("Failed to reassign stderr to " TTY);
  }

  /* If here, INITSCRIPT or spawn an interactive shell.
   */

  if(argc == 2 && !strcmp(argv[1], "ishell"))
  {
    if(!fork())
    {
      if(execve("/bin/busybox", ishell_args, empty_env_execve) == -1)
      {
        syscall_fail("Failed to launch interactive shell");
      }
    }
    else
    {
      if(!fork())
      {
        if(execve(INITSCRIPT, initscript_args, empty_env_execve) == -1)
        {
          syscall_fail("Failed to run initialization script " INITSCRIPT);
        }
      }
    }
  }

  /* The init process must not die, and no busy wait so call sleep function.
   */
  sleep();
}
