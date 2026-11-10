% Ansible for the impatient
% Jim Davis
  UITS System Administration and Security group
  jjdavis@arizona.edu
% November 10th, 2026

---

# What is Ansible?

From the Ansible github repo,

> Ansible is a radically simple IT automation platform that makes your
> applications and systems easier to deploy and maintain. Automate
> everything from code deployment to network configuration to cloud
> management, in a language that approaches plain English, using SSH,
> with no agents to install on remote systems.

---

- Ansible is free and open source software, released under the GPL-3.0
  software license.

- The git repo at <https://github.com/ansible/ansible> has over 5,555
  contributors.

- There's extensive online [documentation](https://docs.ansible.com).

- An Ansible [forum](https://forum.ansible.com) provides community support.

- RedHat also sells a [commercial](https://www.redhat.com/en/technologies/management/ansible) version of Ansible.

---

# Infrastructure as code

As Wikipedia [describes](https://en.wikipedia.org/wiki/Infrastructure_as_code),

> Infrastructure as code (IaC) is the process of managing and
> provisioning computer data center resources through machine-readable
> definition files, rather than via physical hardware configuration or
> interactive configuration tools.

---

The DIY years of IaC: [RCS](https://pages.cs.wisc.edu/~plonka/sysadmin/article.html) and [rdist](https://www.cs.umb.edu/~ckelly/teaching/common/project/linux/sys_admin/p7_rdist.pdf) and shell scripts, oh my.  Then Cfengine appeared in 1993, followed by

- Puppet, 2005 
- Chef, 2009 
- SaltStack, 2011
- Ansible, 2012

Wikipedia has a more extensive [list](https://en.wikipedia.org/wiki/Comparison_of_open-source_configuration_management_software), with some comparison of features.

---

# Ansible architecture

- One computer is the control node.

- One or more computers are the managed nodes, also called remote
  nodes in the documentation.

- The control node needs to have ssh access to the managed nodes, and
  in most cases needs to have root access on the managed nodes to do
  anything interesting.

---

# Setting up Ansible on the control node

Control nodes can run Linux or MacOS.

1. Install the Ansible software.
2. Set up a configuration file.
3. Create an inventory file of managed nodes.

---

# Install the Ansible software

- [Install](https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html) Ansible from a Linux distribution package.  Any major Linux distribution should have a package available.

- Or install on Linux or MacOS via pipx.  The package version may be
  slightly older.

---

# Set up a configuration file

There are many [configuration](https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_configuration.html) options, but all have defaults.
Ansible will look for the configuration file in /etc/ansible/ansible.cfg or several other locations.

---

Run 

    ansible-config init --disabled -t all

on the control node if you want to see all the defaults.

---

Run 

    ansible-config init

on the control node to create an initial configuration.

---

Run 

    ansible-config validate

on the control node to check that your configuration file is valid.

---

# Create an inventory file of managed nodes

Ansible will only attempt to manage computers listed in the inventory file.

The [inventory file](https://docs.ansible.com/projects/ansible/latest/inventory_guide/index.html) can be in YAML or ini format. Ansible will look in /etc/ansible/hosts or several other locations.

---

Run

    ansible-inventory --list

on the control node to check that the inventory is valid.

---

# Setting up Ansible on the managed nodes

Ansible managed nodes can run Linux, Windows, FreeBSD, or z/OS
UNIX, though there are some
[caveats](https://docs.ansible.com/projects/ansible/latest/os_guide/index.html)
for non-Linux managed nodes.

---

- You don't have to install an Ansible client or agent on the managed
  nodes.

- However, the managed nodes will need a recent version of Python
  installed.

- You also will need to arrange for the control node to access the
  managed nodes via ssh, and typically with root privileges.

---

# Using Ansible

- Ansible provides a toolkit of modules that correspond to many
  system administration tasks.

- For example, the ansible.builtin.user module can add, or remove, or
  modify user accounts.

- In many references you'll see ansible.builtin.user (the
  [fully qualified collection name](https://docs.ansible.com/projects/ansible/latest/reference_appendices/glossary.html#term-Fully-Qualified-Collection-Name-FQCN)) shortened to just ansible.user.

---

- Ansible provides core modules like ansible.builtin.user but there
  are community modules too, provided by third parties.

- The community module ansible.posix.authorized_key, for instance,
  can manage user's ssh authorized keys files.
  
- Community module collections may need to be installed
  separately. The core modules are installed by default.

---

Start with some goal, say to add user accounts, find the Ansible
module that handles that, and write a playbook calling that module.

- A playbook is a text file in YAML format.

- The individual actions (plays) in the playbook run sequentially.

---

Run the playbook with 

    ansible-playbook playbook-name

on the control node.
 
---

# The joys of YAML

- When editing playbooks be very careful about indentation!  Things
  must line up just so or Ansible will complain.  And Ansible
  error messages can be opaque.

- Tabs can't be used in playbooks, though here Ansible will give
  you a more informative error message.
  
---

Check for syntax errors in playbooks by running 

    ansible-playbook --syntax-check playbook

---

# Example - adding user accounts 

Suppose you want to create new accounts for four users on Ubuntu,
Debian, and Fedora managed nodes.  Two of the users should have sudo
access.

---

# Adding users, basic version

[addusers-basic.yml](https://github.com/jjdavis5678/afti/blob/main/addusers-basic.yml)

The ansible.builtin.user module adds user accounts in this playbook.

---

# Adding users, with sudo access

[add-to-sudo-group.yml](https://github.com/jjdavis5678/afti/blob/main/add-to-sudo-group.yml)

Now let's give two of the new users sudo access. This playbook fails on
the Fedora managed node.  What went wrong?

---

Ansible can hide the syntax differences between adding users on Ubuntu
or Debian or Fedora, but the sudo group on Fedora is wheel, not
sudo.  We need a way to tell Ansible to use the wheel group on
Fedora and the sudo group otherwise.

---

We can tell Linux distributions apart by looking at the extensive
setup information Ansible collects for each managed node.  Running

    ansible -m setup fedora

on the control node and grepping for 'distribution' returns, in part,
"ansible_distribution":"Fedora" and we can use that fact in the
playbook.

---

# Adding users, with sudo via the distribution variable

[add-to-sudo-group-var.yml](https://github.com/jjdavis5678/afti/blob/main/add-to-sudo-group-var.yml)

Using variables in Ansible can be [complicated](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_variables.html#understanding-variable-precedence) but here we just need one variable set to account for the different sudo groups.

The playbook tags lets you selectively add accounts.

---

# Adding ssh keys

[addusers-sshkeys.yml](https://github.com/jjdavis5678/afti/blob/main/addusers-sshkeys.yml)

This playbook uses a community module, ansible.posix.authorized_key.

It also uses an included file for variables, either Debian.yml or
RedHat.yml, depending on the value of the os_family variable.  And it
uses the block playbook statement to group related plays together.

---

# Removing user accounts

[rmusers.yml](https://github.com/jjdavis5678/afti/blob/main/rmusers.yml)

Using tags lets you selectively remove accounts.

---

# Selecting hosts or plays

Running the addusers-basic.yml playbook with the command line argument

    --limit fedora,trixie

would add user accounts only on those two managed nodes.
 
---

Running the add-to-sudo-group.yml playbook with the command line argument

    --tags include,debug

would just display the value of the included variable and skip the other plays.

---

# Playbook idempotentcy

[Idempotentcy](https://www.merriam-webster.com/dictionary/idempotent) is a big word imported from mathematics.

Ansible uses it to mean that if you run the same playbook on the same
managed node, the playbook will only make changes once.  This is
useful for development, since the parts of the playbook that did work
won't run again while you debug the rest.  It's useful for production
too.

---

# Example - running commands

Sometimes you need to run a shell command or two.  Ansible can
accommodate that.

---

# The command and shell modules

[timezone.yml](https://github.com/jjdavis5678/afti/blob/main/timezone.yml)

This playbook sets the timezone on the managed nodes to America/Phoenix
using the ansible.builtin.command and ansible.builtin.shell
modules, and by capturing the output of the timedatectl program on
the managed node in a variable.

---

The ansible.builtin.command module is meant for running programs;
ansible.builtin.shell runs programs too but with the usual shell
redirection and pipes as well.

---

# Using 'changed_when' in playbooks

Using shell commands tosses idempotency away, but there's a way to
paper over that: using the changed_when statement can modify the usual
output about changed plays when running a playbook.

---

# Example - installing programs

The next playbooks work through three common scenarios for installing programs on managed nodes

- Installing programs from distribution packages

- Installing programs from project packages

- Installing programs from project downloads

---

# Installing programs from distribution packages

[installprogs-distro-pkgs.yml](https://github.com/jjdavis5678/afti/blob/main/installprogs-distro-pkgs.yml)

This playbook uses the ansible.builtin.package module to install
packages that have the same name across Ubuntu, Debian, and Fedora.
For the more complicated case where the package names differ, it uses
ansible.builtin.apt or ansible.builtin.dnf instead.  Those modules are
wrappers around the native apt and dnf programs respectively.

---

Here we need to differentiate not only between Debian or Fedora OS
families but also between Ubuntu releases; there's a more complicated
variable inclusion setup than in previous playbooks to handle that.

---

# Installing programs from project packages

[installprogs-project-pkgs.yml](https://github.com/jjdavis5678/afti/blob/main/installprogs-project-pkgs.yml)

This sets up the postgresql database server from the project's own
repo packages. It uses the ansible.builtin.fetch_url and
ansible.builtin.deb822 packages to configure the postgresql repos on
the managed node.

--- 

The last play calls ansible.builtin.systemd_service to enable and
start postgresql.  While this usually happens automatically when a
package is installed, since the playbook is idempotent it doesn't hurt
to add this.  If systemd has already enabled and started postgresql,
the play will be skipped.

---

# Installing programs from project downloads

[installprogs-project-downloads.yml](https://github.com/jjdavis5678/afti/blob/main/installprogs-project-downloads.yml)

For the last installation example, a [restic](https://restic.net)
executable is downloaded to the control node and then pushed from the
control node to the managed nodes, rather than having each managed
node download a separate copy.  The restic project provides a single
file with checksums for all possible downloads, but we must pick out
the checksum we want.

---

This playbook uses [handlers](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_handlers.html) to uncompress and install the restic executable, but only if the download succeeded and the checksum matches.

---

While Ansible usually runs in a push model, this playbook suggests
how you could use Ansible in a pull model too: pull playbooks from
some source to the local computer, which has ansible installed, and
then execute those playbooks on the local computer.

---

# Organizing playbooks, and Ansible roles

After writing a bunch of Ansible playbooks, you'll have quite a
clutter of playbooks.  There are options to organize them.

---

One possibility is to write a master playbook of playbooks --
conventionally called site.yml -- that includes all the other
playbooks, or at least all the others you want to run on all the
managed nodes.  That would make use of the
ansible.builtin.import_playbook module.

---

The all-singing, all-dancing version of that is to use Ansible
[roles](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html). Roles
let you bundle separate groups of playbooks and variables and
inventory files and whatever else into a standard directory
structure.

---

So instead of, say, database playbooks and database variables files
jostling with your webserver playbooks and variables files, they could
be separated into a database role and a webserver role in separate
directory trees.  For large, complicated setups that could be useful.
