require File.expand_path('../spec_helper', __FILE__)

# rubocop:disable Metrics/ModuleLength, Metrics/BlockLength

module Danger
  describe Danger::DangerIosLogs do
    it 'should be a plugin' do
      expect(Danger::DangerIosLogs.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @ios_logs = @dangerfile.ios_logs
      end

      context 'changed files containing newly introduced todos' do
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

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with('some/file.rb').and_return(modified)

          allow(@dangerfile.git).to receive(:diff_for_file)
            .with('another/stuff.rb').and_return(added)

          allow(@dangerfile.git).to receive(:modified_files)
            .and_return(['some/file.rb'])
          allow(@dangerfile.git).to receive(:added_files)
            .and_return(['another/stuff.rb'])
        end

        it 'warns when files in the changeset' do
          @ios_logs.check

          expect(warnings.length).to eq(3)
          expect(warnings[0]).to \
            eq('There remain `print` in the modified code.')
          expect(warnings[1]).to \
            eq('There remain `print` in the modified code.')
          expect(warnings[2]).to \
            eq('There remain `NSLog` in the modified code.')
        end

        it 'fails when files in the changeset' do
          @ios_logs.check :fail

          expect(failures.length).to eq(3)
          expect(failures[0]).to \
            eq('There remain `print` in the modified code.')
          expect(failures[1]).to \
            eq('There remain `print` in the modified code.')
          expect(failures[2]).to \
            eq('There remain `NSLog` in the modified code.')
        end

        it 'exposes logs to the dangerfile' do
          @ios_logs.check

          expect(@ios_logs.prints.length).to eq(2)
          expect(@ios_logs.prints[0]).to \
            eq(Danger::FileLog.new('some/file.rb', 3))
          expect(@ios_logs.prints[1]).to \
            eq(Danger::FileLog.new('another/stuff.rb', 0))

          expect(@ios_logs.nslogs.length).to eq(1)
          expect(@ios_logs.nslogs[0]).to \
            eq(Danger::FileLog.new('some/file.rb', 0))

          expect(@ios_logs.logs.length).to eq(3)
          expect(@ios_logs.logs[0]).to \
            eq(Danger::FileLog.new('some/file.rb', 3))
          expect(@ios_logs.logs[1]).to \
            eq(Danger::FileLog.new('another/stuff.rb', 0))
          expect(@ios_logs.logs[2]).to \
            eq(Danger::FileLog.new('some/file.rb', 0))
        end
      end

      context 'changed files not containing a NSLog nor print' do
        before do
          modified = Git::Diff::DiffFile.new(
            'base',
            path:  'some/file.rb',
            patch: '+ some added line'
          )
          allow(@dangerfile.git).to receive(:diff_for_file)
            .with('some/file.rb').and_return(modified)

          allow(@dangerfile.git).to receive(:modified_files)
            .and_return(['some/file.rb'])
          allow(@dangerfile.git).to receive(:added_files).and_return([])
        end

        it 'reports nothing' do
          @ios_logs.check

          expect(messages).to be_empty
          expect(warnings).to be_empty
          expect(failures).to be_empty
          expect(markdowns).to be_empty
        end
      end

      it 'does nothing when no files are in changeset' do
        allow(@dangerfile.git).to receive(:modified_files).and_return([])
        allow(@dangerfile.git).to receive(:added_files).and_return([])

        @ios_logs.check

        expect(messages).to be_empty
        expect(warnings).to be_empty
        expect(failures).to be_empty
        expect(markdowns).to be_empty
      end

      it 'does not raise when git returns nil' do
        invalid = [nil, 0, false]
        allow(@dangerfile.git).to receive(:modified_files).and_return(invalid)
        allow(@dangerfile.git).to receive(:added_files).and_return(invalid)

        expect { @ios_logs.check }.to_not raise_error
      end
    end
  end
end
