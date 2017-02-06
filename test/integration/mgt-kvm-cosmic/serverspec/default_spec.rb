require 'spec_helper'

ssh_pass = 'sshpass -p password ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -t root@cs1 '
prepare_compile = ssh_pass + '"cd /data/shared/helper_scripts/cosmic; ./prepare_cosmic_compile.sh -h; ./prepare_cosmic_compile.sh -h"'
build_run_deploy_test = ssh_pass + '"cd /data/shared/helper_scripts/cosmic; ./build_run_deploy_test.sh -m /data/shared/marvin/mct-zone1-kvm1.cfg"'
keep_running = ssh_pass + '"cd /data/git/cs1/cosmic/cosmic-client; screen -dml /usr/lib/jvm/java/bin/java -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 -classpath /usr/share/maven/boot/plexus-classworlds.jar -Dclassworlds.conf=/usr/share/maven/bin/m2.conf -Dmaven.home=/usr/share/maven org.codehaus.plexus.classworlds.launcher.Launcher -pl :cloud-client-ui jetty:run > jetty.log 2>&1 ; sleep 3 "'

describe 'bubble::default' do
  include_examples 'bubble::default_tests'

  include_examples 'bubble::deploy_cs1'
  include_examples 'bubble::check_cs1'

  include_examples 'bubble::deploy_kvm1'
  include_examples 'bubble::check_kvm1'

  describe command(prepare_compile) do
    its(:stdout) {should contain('Git repo already found')}
    its(:stdout) {should contain('/data/git/cs1/cosmic')}
  end

  describe command(build_run_deploy_test) do
    its(:stdout) {should contain('=== Deploy DC Successful ===')}
    its(:stdout) {should contain('All templates are ready!')}
    its(:stdout) {should contain('Finished')}
  end

  describe command(keep_running) do
    its(:exit_status) { should eq 0 }
  end
end
