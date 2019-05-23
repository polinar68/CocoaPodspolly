require File.expand_path('../../../spec_helper', __FILE__)

module Pod
  describe Installer::SandboxDirCleaner do
    before do
      @pod_target = fixture_pod_target('banana-lib/BananaLib.podspec')
      spec = fixture_spec('coconut-lib/CoconutLib.podspec')
      spec.module_name = 'CoconutLibModule'
      @other_pod_target = fixture_pod_target_with_specs([spec])
      @aggregate_target = AggregateTarget.new(config.sandbox, false, {}, [], Platform.ios,
                                              fixture_target_definition('MyApp'), config.sandbox.root.dirname, nil,
                                              nil, {})
      @cleaner = Installer::SandboxDirCleaner.new(config.sandbox, [@pod_target, @other_pod_target], [@aggregate_target])
      @project = Project.new(config.sandbox.project_path)
      @sandbox = config.sandbox
      FileUtils.mkdir_p(@sandbox.target_support_files_dir(@pod_target.name))
      FileUtils.mkdir_p(@sandbox.target_support_files_dir(@other_pod_target.name))
      FileUtils.mkdir_p(@sandbox.target_support_files_dir(@aggregate_target.name))
    end

    it 'Cleans up stale target support directories' do
      unknown_target_path = @sandbox.target_support_files_dir('Pods-Unknown')
      FileUtils.mkdir_p(unknown_target_path)

      @cleaner.expects(:remove_dir).with(unknown_target_path)
      @cleaner.clean!
    end

    it 'does not remove pod or aggregate target support directories' do
      @cleaner.expects(:remove_dir).never
      @cleaner.clean!
    end

    it 'cleans up stale headers and keeps pod target headers' do
      random_pod_private_headers = @pod_target.build_headers.root.join('RandomPod')
      random_pod_public_headers = @sandbox.public_headers.root.join('PublicPod')
      banana_lib_public_headers = @sandbox.public_headers.root.join('BananaLib')
      banana_lib_private_headers = @pod_target.build_headers.root.join('BananaLib')
      coconut_lib_public_headers = @sandbox.public_headers.root.join('CoconutLibModule')
      coconut_lib_private_headers = @pod_target.build_headers.root.join('CoconutLibModule')
      FileUtils.mkdir_p(random_pod_private_headers)
      FileUtils.mkdir_p(random_pod_public_headers)
      FileUtils.mkdir_p(banana_lib_public_headers)
      FileUtils.mkdir_p(banana_lib_private_headers)
      FileUtils.mkdir_p(coconut_lib_public_headers)
      FileUtils.mkdir_p(coconut_lib_private_headers)
      @cleaner.expects(:remove_dir).with(random_pod_private_headers)
      @cleaner.expects(:remove_dir).with(random_pod_public_headers)
      @cleaner.expects(:remove_dir).with(coconut_lib_public_headers).never
      @cleaner.expects(:remove_dir).with(coconut_lib_private_headers)
      @cleaner.clean!
      FileUtils.rm_rf(random_pod_private_headers)
      FileUtils.rm_rf(random_pod_public_headers)
      FileUtils.rm_rf(banana_lib_public_headers)
      FileUtils.rm_rf(banana_lib_private_headers)
      FileUtils.rm_rf(coconut_lib_public_headers)
      FileUtils.rm_rf(coconut_lib_private_headers)
    end
  end
end
