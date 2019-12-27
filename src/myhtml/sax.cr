module Myhtml
  #
  # Html SAX Parser
  #
  class SAX
    abstract class Tokenizer
      property sax : SAX?

      abstract def on_token(token : Token)

      def on_start; end

      def on_done; end
    end

    getter tokenizer : Tokenizer
    getter string : String?
    getter tree

    def raw_tree
      @tree.raw_tree
    end

    def initialize(@tokenizer : Tokenizer, build_tree = false, skip_whitespace_token = true, tree_options = nil)
      to = tree_options || Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_PROCESS_TOKEN

      unless build_tree
        to |= Myhtml::Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_BUILD_TREE
      end

      if skip_whitespace_token
        to |= Myhtml::Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_SKIP_WHITESPACE_TOKEN
      end

      @tree = Tree.new
      @tree.set_flags(to) if to
    end

    # Dangerous, free object
    def free
      @tree.free
    end

    CALLBACK = ->(_tree : Myhtml::Lib::MyhtmlTreeT*, _token : Myhtml::Lib::MyhtmlTokenNodeT*, _ctx : Void*) do
      unless _ctx.null?
        tok = _ctx.as Tokenizer

        unless _token.null?
          tok.on_token(SAX::Token.new(tok, _tree, _token))
        end
      end

      _ctx
    end

    def parse(string, encoding = Lib::MyEncodingList::MyENCODING_UTF_8)
      @string = string
      pointer = string.to_unsafe
      bytesize = string.bytesize

      @tokenizer.sax = self
      @tokenizer.on_start
      Lib.callback_after_token_done_set(@tree.raw_tree, CALLBACK, @tokenizer.as(Void*))
      res = Lib.parse(@tree.raw_tree, encoding, pointer, bytesize)
      raise LibError.new("parse error #{res}") if res != Lib::MyStatus::MyCORE_STATUS_OK

      @tokenizer.on_done
      self
    end
  end
end

require "./sax/*"
