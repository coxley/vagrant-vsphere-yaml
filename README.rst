vagrant-vsphere-yaml
====================

.. image:: http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-2.png
   :target: http://www.wtfpl.net/
   :alt: Do what the fuck you want
   :height: 25px

YAML-powered "box" for the vsphere provider in Vagrant.

I'm terrible at ruby so I wrote this with the goal of mananging my virtual
machines in VMware ESXi without ever touching the Vagrantfile again. It does a
pretty good job, too. 

With this you can avoid using the vSphere web client just to add/restart VMs
and actually version control their basic set ups. Let's go!

Quickstart
----------

Clone repository and install provider::

    git clone https://github.com/coxley/vagrant-vsphere-yaml
    vagrant plugin install vagrant-vsphere
    
Create ``settings.yaml`` and start out with something simple:

.. code:: yaml

    ---
    vcenter:
      host: vcenter.example.com
      user: root
      password: sekrit
      insecure: false  # Set this to true if your SSL certs aren't trusted
   
   hosts:
     - name: web01
       clone_from_vm: true
       template_name: webs  # Replace this with the name of an existing VM
     - name: web02
       clone_from_vm: true
       template_name: webs

Finally::

    vagrant up --provider=vsphere

Requirements
------------

Vagrant plugins:

    + vagrant-vsphere

    + vagrant-librarian-puppet `only if wanting to provision with puppet`

Customization spec
------------------

Simple example but this shows how nice it is to use YAML instead of the
Vagrantfile directly to set hosts up. You'll notice, thouh, that the hostname 
doesn't get changed from the cloned/templated VM. This has to do with how the
``vagrant-vsphere`` relies on vCenter's custimization specs for changing IP
addresses, host names, and several other things that is just easier with
vmtools.

If you don't know what a customization spec is, they're easy to create and just
define a few common options VMs may share such as making the hostname match the
VM name, number of NICs and VLANs thereon. For docs, check out the 
`setup instructions`_. For ease, just create one named ``vagrant0`` with pretty basic
settings and make sure 'Computer Name' is checked for by VM name. Then the
hostname will be set to ``name``.

.. _setup instructions:
   https://pubs.vmware.com/vsphere-4-esx-vcenter/index.jsp#deploy_vms_from_templates_and_clones/c_managing_customization_specifications.html

YAML
----

The hosts you want to manage are defined in a YAML list and accept any of the
parameters shown `here`_

In addition to the provider's options, I've presented some custom ones:

* ``bootstrap``: path to shell script to run on host during provisioning

* ``provision``: if set to ``puppet``, will use puppet to provision and will
  look for ``puppet/manifests/[name].pp``

* ``hiera``: path to hiera config file if you wish to use it with puppet

.. _here: https://github.com/nsidc/vagrant-vsphere#configuration

Defaults
~~~~~~~~

YAML supports reusable blocks, so lets take advantage of that where possible.
See the following example:

.. code:: yaml

    ---
    defaults: &defaults
      mem: 512
      cpu: 1
      spec: vagrant0

    trusty: &trusty
      <<: defaults
      clone_from_vm: true
      template_name: trusty
      provision: puppet

    vcenter:
      host: vcenter.example.com
      user: root
      password: sekrit
      insecure: false

    hosts:
      - name: ns1
        <<: *trusty
      - name: web01
        <<: *trusty

Puppet
------

Even though Vagrant supports puppet-apply provisioning natively, I decided to
have ``vagrant-librarian-puppet`` as a requirement because Puppet doesn't have
a built-in resource for configuring network interfaces. This makes it easy to
install modules for any inital configuring you could need.

Check out ``example/puppet/Puppetfile`` for all that's needed.

``vagrant-vsphere`` doesn't have a way that I'm pleased with to configure
static networking, so please see the example for how I'm configuring that.

VM Requirements
---------------

For everything to work nicely, there are a few requirements for your template.

Check the vagrant user and SSH sections of the `docs`_ and make sure the 
``open-vm-tools`` package is installed. This will ensure vagrant has no trouble
provisioning.

Acknowledgements
----------------

Thanks goes to authors of vagrant-vsphere for writing the provider and also to
scottlowe for writing `this`_ blog post, giving me the idea to write this.

.. _this: http://blog.scottlowe.org/2014/10/22/multi-machine-vagrant-with-yaml/
