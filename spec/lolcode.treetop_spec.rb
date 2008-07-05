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
  # this isn't right, but it is working well-enough for the moment
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
    
    it "should support comma as a comand delimiter" do
      should_parse("HAI,1", 'integer')
    end
  end

  describe "YARN" do
    it "should parse" do
      should_parse(%Q{HAI\n"test"}, 'string')
    end
    
    it "should return value" do
      run(%Q{HAI\n"test"}).should == "test"
    end
    
    escapes = {
      ':)' => "\n",
      ':>' => "\t",
      ':o' => "\g",
      ':"' => '"',
      '::' => ':',
    }
    escapes.each do |input, output|
      it "should parse #{input.inspect} as #{output.inspect}" do
        run(%Q{HAI\n"#{input}"}).should == output
      end
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

  describe "IT" do
    it "should be automatically set by a bare value" do
      run("HAI\n1")
      env['IT'].should == 1
    end

    it "should be automatically set by a bare value expression" do
      run("HAI\nBOTH SAEM 1 AN 2")
      env['IT'].should == false
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

  describe "GIMMEH" do
    it "should parse" do
      should_parse("HAI\nGIMMEH VAR", 'get_line')
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
  
  describe "VAR R 3" do
    it "should parse" do
      should_parse("HAI\nVAR R 123", 'variable_assignment')
    end
    
    it "should assign a value" do
      run("HAI\nI HAS A VAR ITZ 1\nVAR R 123")
      env['VAR'].should == 123
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
  
  describe "TIPE OF" do
    it "should parse" do
      should_parse("HAI\nTIPE OF VAR", 'type_query')
    end

    it "should return NOOB" do
      run("HAI\nI HAS A VAR\nTIPE OF VAR").should == "NOOB"
    end
    
    it "should return TROOF" do
      run("HAI\nTIPE OF WIN").should == "TROOF"
    end

    it "should return YARN" do
      run(%Q{HAI\nTIPE OF "O HAI"}).should == "YARN"
    end

    it "should return NUMBR" do
      run("HAI\nTIPE OF 123").should == "NUMBR"
    end

    it "should return NUMBAR" do
      run("HAI\nTIPE OF 123.456").should == "NUMBAR"
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
  
  describe "IZ" do
    it "should parse" do
      should_parse("HAI\nIZ BOTH SAEM 1 AN 1? KTHX", 'short_if')
    end
    
    it "should execute" do
      run("HAI\n\nIZ BOTH SAEM 1 AN 1? I HAS A VAR ITZ 1")
      env['VAR'].should == 1
    end

    it "should not execute" do
      run("HAI\n\nIZ BOTH SAEM 2 AN 1? I HAS A VAR ITZ 1")
      env['VAR'].should_not == 1
    end
  end
  
  describe "value, O RLY? YA RLY ... OIC" do
    it "should parse" do
      should_parse("HAI\nWIN, O RLY?\nYA RLY\nOIC", 'if')
    end

    it "should execute YA RLY" do
      run("HAI\nWIN, O RLY?\nYA RLY\nI HAS A YA ITZ 1\nOIC")
      env['YA'].should == 1
    end

    it "should not execute YA RLY" do
      run("HAI\nFAIL, O RLY?\nYA RLY\nI HAS A YA ITZ 1\nOIC")
      env['YA'].should be_nil
    end
  end

  describe "value, O RLY? YA RLY ... NO WAI ... OIC" do
    it "should parse" do
      should_parse("HAI\nWIN, O RLY?\nYA RLY\nNO WAI\nOIC", 'if')
    end
    
    it "should execute YA RLY" do
      run("HAI\nWIN, O RLY?\nYA RLY\nI HAS A YA ITZ 1\nNO WAI\nI HAS A NO ITZ 2\nOIC")
      env['YA'].should == 1
    end

    it "should not execute YA RLY" do
      run("HAI\nFAIL, O RLY?\nYA RLY\nI HAS A YA ITZ 1\nNO WAI\nI HAS A NO ITZ 2\nOIC")
      env['YA'].should be_nil
    end

    it "should execute NO WAI" do
      run("HAI\nFAIL, O RLY?\nYA RLY\nI HAS A YA ITZ 1\nNO WAI\nI HAS A NO ITZ 2\nOIC")
      env['NO'].should == 2
    end

    it "should execute NO WAI" do
      run("HAI\nWIN, O RLY?\nYA RLY\nI HAS A YA ITZ 1\nNO WAI\nI HAS A NO ITZ 2\nOIC")
      env['NO'].should be_nil
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