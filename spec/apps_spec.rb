require 'spec_helper'

describe 'dokku::apps' do
  let(:chef_runner) do 
    ChefSpec::Runner.new do |node|
      node.set['dokku']['apps'] = {
        'testapp' => {
          'env' => {
            'var1' => 'a',
            'var2' => 'b'
          }
        },
        'testapp2' => {
          'remove' => true
        },
        'testapp3' => {}
      }
    end
  end
  let(:chef_run) { chef_runner.converge described_recipe }

  it 'should create the testapp directory under /home/git' do
    expect(chef_run).to create_directory '/home/git/testapp'
  end

  it 'should set the ownership of the testapp directory to git:git' do
    app1_dir = chef_run.directory('/home/git/testapp')
    expect(app1_dir.owner).to eq('git')
    expect(app1_dir.group).to eq('git')
  end

  it 'should delete the testapp2 directory under /home/git' do
    expect(chef_run).to delete_directory '/home/git/testapp2'
  end

  it 'should remove the app/testapp2 docker container' do
    expect(chef_run).to remove_docker_container 'app/testapp2'
  end

  it 'should remove the app/testapp2 docker image' do
    expect(chef_run).to remove_docker_image 'app/testapp2'
  end

  it 'should not create an ENV file for testapp2' do
    expect(chef_run).to_not create_file '/home/git/testapp2/ENV'
  end

  it 'should create the an ENV for testapp' do
    expect(chef_run).to render_file("/home/git/testapp/ENV").with_content("export VAR1='a'\nexport VAR2='b'")
  end

  it 'should set the ownership of the ENV file to git:git' do
    env_file = chef_run.template('/home/git/testapp/ENV')
    expect(env_file.owner).to eq('git')
    expect(env_file.group).to eq('git')
  end
end
