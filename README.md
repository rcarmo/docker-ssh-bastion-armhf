# docker-ssh-bastion-armhf

A Docker container with a tailored SSH server, to act as a bastion host. Some of the things below can be easily tuned to your liking.

* [x] Use `bash` instead of `busybox` to reduce number of commands available (Alpine uses `busybox` for everything, and I don't want people to be able to do `busybox ls`).
* [x] Lock down capabilities to absolute minimum
* [x] Allow for a PTY (because I cannot specify a `ProxyCommand` on some mobile SSH clients and thus need to type `ssh foo` again)
* [x] Mount existing `authorized_keys` inside the container, read-only
* [x] Lock down SSH for key-based auth only
* [x] Remove unused commands, SUID files, etc

