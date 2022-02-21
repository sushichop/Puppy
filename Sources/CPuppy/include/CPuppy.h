#ifndef CPUPPY_H
#define CPUPPY_H

#if defined(__cplusplus)
extern "C" {
#endif


#if defined(__linux__)

#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>

static inline unsigned long long cpuppy_sys_gettid(void) {
    return syscall(SYS_gettid);
}

#include <syslog.h>

static inline void cpuppy_syslog(int priority, const char *message) {
    syslog(priority, "%s", message);
}

#endif // __linux__


#if defined(__cplusplus)
} // extern "C"
#endif

#endif // CPUPPY_H
