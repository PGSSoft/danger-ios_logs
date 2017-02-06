require File.expand_path('../spec_helper', __FILE__)
require 'shared_example_groups/files_in_changeset'
require 'shared_example_groups/files_not_in_changeset'
require 'shared_example_groups/logs_in_dockerfile'

# rubocop:disable Metrics/BlockLength

module Danger
  describe Danger::DangerIosLogs do
    it 'should be a plugin' do
      expect(described_class).to be < Danger::Plugin
    end

    context 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @ios_logs = @dangerfile.ios_logs
      end

      context 'changed files containing newly introduced logs' do
        before do
          patch = <<PATCH
+ NSLog("Some log")
+ func foo() {
+ }
+ print("Some other log")
PATCH

          modified = Git::Diff::DiffFile.new(
            'base',
            path:  'some/file.rb',
            patch: patch
          )
          added = Git::Diff::DiffFile.new(
            'base',
            path:  'another/stuff.rb',
            patch: '+ print(\"More logs\")'
          )

          allow(@dangerfile.git).to receive(:diff_for_file).with('some/file.rb').and_return(modified)
          allow(@dangerfile.git).to receive(:diff_for_file).with('another/stuff.rb').and_return(added)
          allow(@dangerfile.git).to receive(:modified_files).and_return(['some/file.rb'])
          allow(@dangerfile.git).to receive(:added_files).and_return(['another/stuff.rb'])
        end

        some_file_0th_line = Danger::FileLog.new('some/file.rb', 0)
        some_file_3rd_line = Danger::FileLog.new('some/file.rb', 3)
        another_stuff = Danger::FileLog.new('another/stuff.rb', 0)

        context 'warns when files in the changeset' do
          before do
            @ios_logs.check
          end

          it_behaves_like 'files in changeset' do
            let(:log_method) { warnings }
          end
        end

        context 'fails when files in the changeset' do
          before do
            @ios_logs.check :fail
          end

          it_behaves_like 'files in changeset' do
            let(:log_method) { failures }
          end
        end

        context 'expose logs to the dangerfile' do
          before do
            @ios_logs.check
          end

          it_behaves_like 'logs in dockerfile', [some_file_3rd_line, another_stuff] do
            let(:logs) { @ios_logs.prints }
          end

          it_behaves_like 'logs in dockerfile', [some_file_0th_line] do
            let(:logs) { @ios_logs.nslogs }
          end

          it_behaves_like 'logs in dockerfile', [some_file_3rd_line, another_stuff, some_file_0th_line] do
            let(:logs) { @ios_logs.logs }
          end
        end
      end

      context 'changed files not containing a NSLog nor print' do
        before do
          modified = Git::Diff::DiffFile.new(
            'base',
            path:  'some/file.rb',
            patch: '+ an added line'
          )
          allow(@dangerfile.git).to receive(:diff_for_file).with('some/file.rb').and_return(modified)
          allow(@dangerfile.git).to receive(:modified_files).and_return(['some/file.rb'])
          allow(@dangerfile.git).to receive(:added_files).and_return([])

          @ios_logs.check
        end

        it_behaves_like 'files not in changeset'
      end

      context 'no files are in changeset' do
        before do
          allow(@dangerfile.git).to receive(:modified_files).and_return([])
          allow(@dangerfile.git).to receive(:added_files).and_return([])

          @ios_logs.check
        end

        it_behaves_like 'files not in changeset'
      end

      it 'does not raise when git returns nil' do
        invalid = [nil, 0, false]
        allow(@dangerfile.git).to receive(:modified_files).and_return(invalid)
        allow(@dangerfile.git).to receive(:added_files).and_return(invalid)

        expect { @ios_logs.check }.to_not raise_error
      end

      it 'raise if used wrong method' do
        expect { @ios_logs.check(:wrong_method) }.to raise_error('Unsupported method')
      end
    end
  end
end
