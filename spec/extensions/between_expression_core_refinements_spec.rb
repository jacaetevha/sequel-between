# frozen-string-literal: true

require_relative '../spec_helper'

if defined?(Sequel::CoreRefinements)
  using Sequel::CoreRefinements

  describe 'with core_refinements: between extension' do
    let(:dbf) do
      lambda do |db_type|
        db = Sequel.connect("mock://#{db_type}")
        db.extension :between
        db
      end
    end

    it 'should support Symbol.between on SQL Server' do
      expect(dbf[:sqlserver].literal(:a.between(:b, :c))).to eq '(a BETWEEN b AND c)'
    end

    it 'should support Symbol.between on SQLite' do
      expect(dbf[:sqlite3].literal(:a.between(:b, :c))).to eq '(a BETWEEN b AND c)'
    end

    it 'should support Symbol.between on PG' do
      expect(dbf[:postgres].literal(:a.between(:b, :c))).to eq '("a" BETWEEN "b" AND "c")'
    end

    it 'should support Symbol.not_between on SQL Server' do
      expect(dbf[:sqlserver].literal(:d.not_between(:e, :f))).to eq '(d NOT BETWEEN e AND f)'
    end

    it 'should support Symbol.not_between' do
      expect(dbf[:postgres].literal(:d.not_between(:e, :f))).to eq '("d" NOT BETWEEN "e" AND "f")'
    end

    it 'should support Symbol.not_between on SQLite' do
      expect(dbf[:sqlite3].literal(:a.not_between(:b, :c))).to eq '(a NOT BETWEEN b AND c)'
    end
  end
end
