require 'rubygems'
require 'spec/runner'

dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

context "A sequence parsing expression with one element" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @sequence = Sequence.new([@elt])
  end
    
  specify "attempts to parse its single element upon a call to parse_at" do
    setup_sequence_element_to_successfully_parse
    @sequence.parse_at(@input, @index, @parser)
  end
  
  specify "returns a SequenceSyntaxNode with the element's parse result as an element if the parse is successful" do
    setup_sequence_element_to_successfully_parse
    result = @sequence.parse_at(@input, @index, @parser)
    result.should_be_a_kind_of SequenceSyntaxNode
    result.elements.should_eql [@elt_result]
  end  
end

context "A sequence parsing expression with multiple terminal symbols as elements" do
  setup do
    @elts = ["foo", "bar", "baz"]
    @sequence = Sequence.new(@elts.collect { |w| TerminalSymbol.new(w) })
  end
  
  specify "returns a successful result with correct elements when matching input is parsed" do
    input = @elts.join
    index = 0
    result = @sequence.parse_at(input, index, parser_with_empty_cache_mock)
    result.should_be_success
    (result.elements.collect {|elt| elt.text_value}).should_eql @elts
    result.consumed_interval.end.should_equal index + input.size
  end
  
  specify "returns a successful result with correct elements when matching input is parsed when starting at a non-zero index" do
    input = "----" + @elts.join
    index = 4
    result = @sequence.parse_at(input, index, parser_with_empty_cache_mock)
    result.should_be_success
    (result.elements.collect {|elt| elt.text_value}).should_eql @elts
    result.consumed_interval.end.should_equal index + @elts.join.size
  end
  
  specify "has a string representation" do
    @sequence.to_s.should == '("foo" "bar" "baz")'
  end
end

context "A sequence parsing expression with one element and a method defined in its node class" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @sequence = Sequence.new([@elt])
    @sequence.node_class_eval do
      def method
      end
    end
  end
  
  specify "returns a SequenceSyntaxNode with the element's parse result as an element if the parse is successful" do
    setup_sequence_element_to_successfully_parse
    result = @sequence.parse_at(@input, @index, @parser)
    result.should_respond_to :method
  end  
end

context "A sequence parsing expression with one element and a method defined in its node class via a string evaluation" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @sequence = Sequence.new([@elt])
    @sequence.node_class_eval("def a_method\n\nend")
  end
  
  specify "returns a SequenceSyntaxNode with the element's parse result as an element if the parse is successful" do
    setup_sequence_element_to_successfully_parse
    result = @sequence.parse_at(@input, @index, @parser)
    result.should_respond_to :method
  end  
end

# context "A sequence of two terminals, when the second terminal returns a parse failure" do
#   setup do
#     @terminal_1 = TerminalSymbol.new('{')
#     @terminal_2 = TerminalSymbol.new('}')
#     @sequence = Sequence.new([@terminal_1, @terminal_2])
#   end
#   
#   specify "returns a parse failure with the second terminal's parse failure as a nested failure" do
#     result = @sequence.parse_at('{x', 0, parser_with_empty_cache_mock)
#     result.should be_failure
#     failure_paths = result.failure_paths
#     
#     failure_paths.size.should == 1
#     terminal_failure = failure_paths[0]
#     
#     terminal_failure.index.should == 1
#     terminal_failure.terminal_index
#   end
# end

def setup_sequence_element_to_successfully_parse  
  @input = "foo"
  @index = 0
  @parser = parser_with_empty_cache_mock
  
  @elt_result = mock("First element's parse result")
  @elt_consumed_interval = 0...5
  @elt_result.stub!(:failure?).and_return(false)
  @elt_result.stub!(:consumed_interval).and_return(@elt_consumed_interval)

  @elt.should_receive(:parse_at).with(@input, @index, @parser).and_return(@elt_result)
end