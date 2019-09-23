require 'minitest_helper'

describe 'SyntaxParser' do

  let(:parser) { Rasti::DB::NQL::SyntaxParser.new }

  def parse(expression)
    parser.parse(expression).tap do |tree|
      tree.wont_be_nil
    end
  end

  describe 'Comparison' do

    describe 'Comparators' do
      
      ['=', '!=', '>', '>=', '<', '<=', '~', ':', '!:'].each do |comparator|
        it "must parse expression with '#{comparator}'" do
          tree = parse "column #{comparator} value"

          proposition = tree.proposition
          proposition.must_be_instance_of Rasti::DB::NQL::Nodes::Comparison
          proposition.comparator.text_value.must_equal comparator
          proposition.left.text_value.must_equal 'column'
          proposition.right.text_value.must_equal 'value'
        end
      end

    end

    it "must parse expression without spaces between elements" do
      tree = parse 'column=value'

      proposition = tree.proposition
      proposition.must_be_instance_of Rasti::DB::NQL::Nodes::Comparison
      proposition.comparator.text_value.must_equal '='
      proposition.left.text_value.must_equal 'column'
      proposition.right.text_value.must_equal 'value'
    end

    describe 'Right hand Operand' do

      it 'must parse expression with integer' do
        tree = parse 'column = 1'

        right_hand_operand = tree.proposition.right
        right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::Integer
        right_hand_operand.value.must_equal 1
      end

      it 'must parse expression with float' do
        tree = parse 'column = 2.3'

        right_hand_operand = tree.proposition.right
        right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::Float
        right_hand_operand.value.must_equal 2.3
      end

      it 'must parse expression with true' do
        tree = parse 'column = true'

        right_hand_operand = tree.proposition.right
        right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::True
        right_hand_operand.value.must_equal true
      end

      it 'must parse expression with false' do
        tree = parse 'column = false'

        right_hand_operand = tree.proposition.right
        right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::False
        right_hand_operand.value.must_equal false
      end

      it 'must parse expression with string' do
        tree = parse 'column = String1'

        right_hand_operand = tree.proposition.right
        right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::String
        right_hand_operand.value.must_equal 'String1'
      end

      it 'must parse expression with literal string' do
        tree = parse 'column = "a & (b | c) | d"'

        right_hand_operand = tree.proposition.right
        right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::LiteralString
        right_hand_operand.value.must_equal 'a & (b | c) | d'
      end

      describe 'Time' do

        it 'must parse expression with hours and minutes' do
          tree = parse 'column > 12:20'

          right_hand_operand = tree.proposition.right
          right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::Time
          right_hand_operand.value.must_equal Timing::TimeInZone.parse('12:20')
        end

        it 'must parse expression with date, hours, minutes and seconds' do
          tree = parse 'column > 2019-03-27T12:20:00'

          right_hand_operand = tree.proposition.right
          right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::Time
          right_hand_operand.value.must_equal Timing::TimeInZone.parse('2019-03-27T12:20:00')
        end

        it 'must parse expression with date, hours, minutes, seconds and timezone' do
          tree = parse 'column > 2019-03-27T12:20:00-03:00'

          right_hand_operand = tree.proposition.right
          right_hand_operand.must_be_instance_of Rasti::DB::NQL::Nodes::Constants::Time
          right_hand_operand.value.must_equal Timing::TimeInZone.parse('2019-03-27T12:20:00-03:00')
        end

      end
    
    end

    it 'must parse expression with field with tables' do
      tree = parse 'relation_table_one.relation_table_two.column = 1'

      left_hand_operand = tree.proposition.left
      left_hand_operand.tables.must_equal ['relation_table_one', 'relation_table_two']
      left_hand_operand.name.must_equal 'column'
    end

  end

  it 'must parse parenthesis sentence' do
    tree = parse '(column: name)'

    tree.proposition.sentence.text_value.must_equal 'column: name'
  end

  describe 'Conjunction' do

    it 'must parse conjunction of two comparisons' do
      tree = parse 'column_one != 1 & column_two: name'
      
      proposition = tree.proposition
      proposition.must_be_instance_of Rasti::DB::NQL::Nodes::Conjunction
      proposition.values.map(&:text_value).zip(['column_one != 1', 'column_two: name']).each do |actual, expected|
        actual.must_equal expected
      end
    end

    it 'must parse conjunction of three comparisons' do
      tree = parse 'column_one > 1 & column_two: name & column_three < 9.2'
      
      proposition = tree.proposition
      proposition.must_be_instance_of Rasti::DB::NQL::Nodes::Conjunction
      proposition.values.zip(['column_one > 1', 'column_two: name ', 'column_three < 9.2']).each do |element, expected_text|
        element.text_value.must_equal expected_text
      end
    end

    it 'must parse conjunction with parenthesis expression' do
      tree = parse '(column_one > 1 | column_two: name) & column_three < 9.2'

      proposition = tree.proposition
      proposition.must_be_instance_of Rasti::DB::NQL::Nodes::Conjunction
      proposition.values.map(&:text_value).zip(['(column_one > 1 | column_two: name)', 'column_three < 9.2']).each do |actual, expected|
        actual.must_equal expected
      end
    end

  end

end