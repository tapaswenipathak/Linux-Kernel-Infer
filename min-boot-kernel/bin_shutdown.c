#include <errno.h>
#include <linux/reboot.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <unistd.h>
#define KILL(a, b) ((kill((a), (b))) ? false: true)

static void syscall_syscall_fail(const char *msg)
{
    fprintf(stderr, "%s: %s\n", msg, strerror(errno));
    exit(1);
}

int main()
{
  printf("%s\n", "Starting sending SIGTERM to processes.");
  if(KILL(-1, SIGTERM))
  {
    syscall_fail("Failed to send SIGTERM to all processes");
  }

  /* Sleep for a second to give processes time to quit.
   */

  sleep(1);

  printf("%s\n", "Starting killing off remaining process with SIGKILL call.");
  if(KILL(-1, SIGKILL))
  {
    syscall_fail("Failed to kill processes with SIGKILL");
  }

  /* Remount root read-only and flush filesystem to clean the disk and buffers.
   */

  printf("%s\n", "Starting remounting read-only and flusing fs.");
  if(mount("", "/", NULL, MS_REMOUNT | MS_RDONLY, NULL) < 0)
  {
    syscall_fail("Failed to remount root read-only");
  }

  sync();

  puts("Shutting down.");


  /* Invoke system power off
   */
  reboot(LINUX_REBOOT_CMD_POWER_OFF);

  /* reboot returns if this executes above call syscall_failed
   */

  syscall_fail("Shutdown syscall_failed");

  return 1;
}
