require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def parse(code)
  LOLCodeParser.new.parse(code.to_s + "\n")
end

def run(code)
  parse(code).run
end

def should_parse(code, node)
  (parsed = parse(code)).should_not be_nil
  parsed.extension_modules.include?(eval("LOLCode::#{node.capitalize}0")).should_not be_nil
end

def should_not_parse(code)
  parse(code).should be_nil
end

describe "LOLCode" do
  describe "HAI" do
    it "should parse" do
      should_parse('HAI', 'program')
    end

    it "should be required" do
      should_not_parse('')
    end
  end
  
  describe "KTHXBYE" do
    it "should parse" do
      should_parse("HAI\nKTHXBYE", 'exit')
    end
  end
  
  
end