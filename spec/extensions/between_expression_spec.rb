# frozen-string-literal: true

require_relative '../spec_helper'

describe 'between extension' do
  let(:dbf) do
    lambda do |db_type|
      db = Sequel.connect("mock://#{db_type}")
      db.extension :between
      db
    end
  end

  context 'postgres' do
    let(:db) { dbf[:postgres] }

    it 'should support Sequel.between' do
      expect(db.literal(Sequel.between(:a, :b, :c))).to eq '("a" BETWEEN "b" AND "c")'
    end

    it 'should support Sequel.not_between' do
      expect(db.literal(Sequel.not_between(:d, :e, :f))).to eq '("d" NOT BETWEEN "e" AND "f")'
    end

    it 'should support between on Sequel expressions' do
      expect(db.literal(Sequel[:a].between(:b, 2))).to eq '("a" BETWEEN "b" AND 2)'
    end

    it 'should support not_between on Sequel expressions' do
      expect(db.literal(Sequel[:a].not_between(:b, 2))).to eq '("a" NOT BETWEEN "b" AND 2)'
    end

    it 'should support between on literal strings' do
      expect(db.literal(Sequel.lit('a').between(:b, 's'))).to eq %{(a BETWEEN "b" AND 's')}
    end

    it 'should support not_between on literal strings' do
      expect(db.literal(Sequel.lit('a').not_between(:b, 's'))).to eq %{(a NOT BETWEEN "b" AND 's')}
    end

    it 'should support between on identifiers' do
      expect(db.literal(Sequel.identifier('a').between(:b, 's'))).to eq %{("a" BETWEEN "b" AND 's')}
    end

    it 'should support not_between on identifiers' do
      expect(db.literal(Sequel.identifier('a').not_between(:b, 's'))).to eq %{("a" NOT BETWEEN "b" AND 's')}
    end
  end

  context 'sqlserver' do
    let(:db) { dbf[:sqlserver] }

    it 'should support Sequel.between' do
      expect(db.literal(Sequel.between(:a, :b, :c))).to eq '(a BETWEEN b AND c)'
    end

    it 'should support Sequel.not_between' do
      expect(db.literal(Sequel.not_between(:d, :e, :f))).to eq '(d NOT BETWEEN e AND f)'
    end

    it 'should support between on Sequel expressions' do
      expect(db.literal(Sequel[:a].between(:b, 2))).to eq '(a BETWEEN b AND 2)'
    end

    it 'should support not_between on Sequel expressions' do
      expect(db.literal(Sequel[:a].not_between(:b, 2))).to eq '(a NOT BETWEEN b AND 2)'
    end

    it 'should support between on literal strings' do
      expect(db.literal(Sequel.lit('a').between(:b, 's'))).to eq %{(a BETWEEN b AND 's')}
    end

    it 'should support not_between on literal strings' do
      expect(db.literal(Sequel.lit('a').not_between(:b, 's'))).to eq %{(a NOT BETWEEN b AND 's')}
    end

    it 'should support between on identifiers' do
      expect(db.literal(Sequel.identifier('a').between(:b, 's'))).to eq %{(a BETWEEN b AND 's')}
    end

    it 'should support not_between on identifiers' do
      expect(db.literal(Sequel.identifier('a').not_between(:b, 's'))).to eq %{(a NOT BETWEEN b AND 's')}
    end
  end
end
