require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def parse(code)
  LOLCodeParser.new.parse(code.to_s + "\n")
end

def run(code)
  @output = parse(code).run 
  @output.first
end

def env
  @output[1]
end

def camelize(text)
  text.split('_').collect do |word|
    word.capitalize
  end.join('')
end

def should_parse(code, node)
  (parsed = parse(code)).should_not be_nil
  parsed.extension_modules.include?(eval("LOLCode::#{camelize(node)}0")).should_not be_nil
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

  describe "YARN" do
    it "should parse" do
      should_parse(%Q{HAI\n"test"}, 'string')
    end
    
    it "should return value" do
      run(%Q{HAI\n"test"}).should == "test"
    end
  end
  
  describe "NUMBR" do
    it "should parse" do
      should_parse("HAI\n5", 'integer')
    end
    
    it "should return value" do
      run("HAI\n5").should == 5
    end
  end

  describe "NUMBAR" do
    it "should parse" do
      should_parse("HAI\n5.2", 'float')
    end
    
    it "should return value" do
      run("HAI\n5.2").should == 5.2
    end
  end
  
  describe "KTHXBYE" do
    it "should parse" do
      should_parse("HAI\nKTHXBYE", 'exit')
    end
  end
  
  describe "I HAS A VAR" do
    it "should parse" do
      should_parse("HAI\nI HAS A VAR", 'variable_declaration')
    end
    
    it "should assign nil" do
      run("HAI\nI HAS A VAR")
      env.include?('VAR').should be_true
    end
  end
  
  
end