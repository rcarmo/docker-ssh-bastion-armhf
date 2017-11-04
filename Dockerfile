FROM rcarmo/alpine:3.6-armhf

RUN apk add --update \
    bash \
    openssh \
    dumb-init \
 && ssh-keygen -A \
 && chown -R sshd:sshd /etc/ssh \
 && chmod 0644 /etc/ssh/* \
 && rm -f /var/cache/apk/*

ADD rootfs /

# I need to be able to login for diagnostic
RUN adduser -D -s /bin/bash bastion
# Without login
#RUN adduser -D -s /sbin/nologin bastion
RUN passwd -u -d bastion \
 && chown -R bastion:bastion /home/bastion/ \
 && chmod -R 0700 /home/bastion/.ssh

# Mount point for our own keys
VOLUME /home/bastion/.ssh

# If you want to bake in authorized_keys instead:
#RUN touch /home/bastion/.ssh/authorized_keys \
# && chmod 0640 /home/bastion/.ssh/authorized_keys

# Remove exploitable binaries
RUN chmod 700 /usr/bin/harden.sh \
 && /usr/bin/harden.sh

EXPOSE 2211 60000-61000/udp
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
