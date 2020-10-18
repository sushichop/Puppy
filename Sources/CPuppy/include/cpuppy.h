#ifndef cpuppy_h
#define cpuppy_h

#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>

static inline unsigned long long sys_gettid_wrapper(void) {
    return syscall(SYS_gettid);
}

#include <syslog.h>

static inline void syslog_wrapper(int priority, const char *message) {
    syslog(priority, "%s", message);
}

#endif /* cpuppy_h */
