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

    it "should parse a leading newline" do
      should_parse("\nHAI", 'program')
    end

    it "should parse extra newlines" do
      should_parse("HAI\n\n\n", 'program')
    end

    it "should be required" do
      should_not_parse('')
    end
  end
  
  describe "basic parsing" do
    it "should parse a leading newline" do
      should_parse("\nHAI", 'program')
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
  
  describe "TROOF" do
    it "should parse" do
      should_parse("HAI\nWIN", 'float')
    end
    
    it "WIN should return true" do
      run("HAI\nWIN").should == true
    end

    it "FAIL should return false" do
      run("HAI\nFAIL").should == false
    end
  end
  
  describe "KTHXBYE" do
    it "should parse" do
      should_parse("HAI\nKTHXBYE", 'exit')
    end
  end

  describe "VISIBLE" do
    it "should parse" do
      should_parse("HAI\nVISIBLE 1", 'print')
    end

    it "should parse with newline disable" do
      should_parse("HAI\nVISIBLE 1!", 'print')
    end
  end
  

  describe "I HAS A VAR" do
    it "should parse" do
      should_parse("HAI\nI HAS A VAR", 'variable_declaration_without_set')
    end
    
    it "should assign nil" do
      run("HAI\nI HAS A VAR")
      env.include?('VAR').should be_true
    end
  end
  
  describe "I HAS A VAR ITZ 5" do
    it "should parse" do
      should_parse("HAI\nI HAS A VAR ITZ 2", 'variable_declaration_with_set')
    end
    
    it "should assign nil" do
      run("HAI\nI HAS A VAR ITZ 2")
      env['VAR'].should == 2
    end
  end
  
  describe "UP VAR!!" do
    it "should parse" do
      should_parse("HAI\nI HAS A VAR ITZ 1\nUP VAR!!", 'increment_variable_without_delta')
    end
    
    it "should increment" do
      run("HAI\nI HAS A VAR ITZ 1\nUP VAR!!")
      env['VAR'].should == 2
    end
  end
  
  describe "UP VAR!!5" do
    it "should parse" do
      should_parse("HAI\nI HAS A VAR ITZ 1\nUP VAR!!1", 'increment_variable_with_delta')
    end

    it "should increment by delta" do
      run("HAI\nI HAS A VAR ITZ 1\nUP VAR!!5")
      env['VAR'].should == 6
    end
  end
  
  describe "BOTH SAEM" do
    it "should parse" do
      should_parse("HAI\nBOTH SAEM 1 AN 2", 'equal')
    end
    
    it "should detect equality" do
      run("HAI\nBOTH SAEM WIN AN WIN").should == true
    end

    it "should detect inequality" do
      run("HAI\nBOTH SAEM WIN AN FAIL").should == false
    end

    it "should work with NUMBRS" do
      run("HAI\nBOTH SAEM 1 AN 2").should == false
    end
  end
  
  describe "O RLY?" do
    it "should parse without NO WAI" do
      should_parse("HAI\nWIN, O RLY?\nYA RLY\nOIC", 'if')
    end

    it "should parse with NO WAI" do
      should_parse("HAI\nWIN, O RLY?\nYA RLY\nNO WAI\nOIC", 'if')
    end
    
    it "should execute YA RLY" do
      run("HAI\nWIN, O RLY?\nYA RLY\nI HAS A VAR ITZ 1\nOIC")
      env['VAR'].should == 1
    end

    it "should not execute YA RLY" do
      run("HAI\nFAIL, O RLY?\nYA RLY\nI HAS A VAR ITZ 1\nOIC")
      env['VAR'].should_not == 1
    end

    it "should execute NO WAI" do
      run("HAI\nFAIL, O RLY?\nYA RLY\nI HAS A VAR ITZ 1\nNO WAI\nI HAS A VAR ITZ 2\nOIC")
      env['VAR'].should == 2
    end
  end

  describe "KTHX" do
    it "should parse" do
      should_parse("HAI\nKTHX", 'break')
    end

    it "should trhow :break" do
      success = true
      catch :break do
        run("HAI\nKTHX")
        success = false
      end
      success.should be_true
    end
  end
  
  describe "IM IN YR LOOPZ" do
    it "should parse" do
      should_parse("HAI\nIM IN YR LOOPZ\nIM OUTTA YR LOOPZ", 'loop')
    end

    it "should loop" do
      run("HAI\nI HAS A VAR ITZ 1\nIM IN YR LOOPZ\nUP VAR!!\nBOTH SAEM VAR AN 3, O RLY?\nYA RLY\nKTHX\nOIC\nIM OUTTA YR LOOPZ")
      env['VAR'].should == 3
    end
  end
  
end