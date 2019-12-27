class Myhtml::Tokenizer
  abstract class State
    abstract def on_token(token)

    def on_begin(tokenizer); end

    def on_end; end
  end

  # Global heap
  HEAP = begin
    tags = Myhtml::Lib.tag_heap_create
    Myhtml::Lib.tag_heap_init(tags, 128)
    tags
  end

  CALLBACK = ->(tkz : Myhtml::Lib::HtmlTokenizerT, token : Myhtml::Lib::HtmlTokenT, ctx : Void*) do
    tag_id = token.value.tag_id

    if tag_id == Myhtml::Lib::TagIdT::LXB_TAG__UNDEF
      tag_id = Myhtml::Lib.html_token_tag_id_from_data(HEAP, token)
      if tag_id == Myhtml::Lib::TagIdT::LXB_TAG__UNDEF
        return Pointer(Void).null.as(Myhtml::Lib::HtmlTokenT)
      else
        token.value.tag_id = tag_id
      end
    end

    unless ctx.null?
      tok = ctx.as(Tokenizer)
      tok.state.on_token(Token.new(tok, token))
    end

    token
  end

  CALLBACK_WO_WHITESPACE_TOKENS = ->(tkz : Myhtml::Lib::HtmlTokenizerT, token : Myhtml::Lib::HtmlTokenT, ctx : Void*) do
    tag_id = token.value.tag_id
    if tag_id == Myhtml::Lib::TagIdT::LXB_TAG__TEXT
      begin_ = token.value.begin_
      slice = Slice.new(begin_, token.value.end_ - begin_)

      whitespaced = slice.all? &.unsafe_chr.ascii_whitespace?

      return token if whitespaced
    end

    if tag_id == Myhtml::Lib::TagIdT::LXB_TAG__UNDEF
      tag_id = Myhtml::Lib.html_token_tag_id_from_data(HEAP, token)
      if tag_id == Myhtml::Lib::TagIdT::LXB_TAG__UNDEF
        return Pointer(Void).null.as(Myhtml::Lib::HtmlTokenT)
      else
        token.value.tag_id = tag_id
      end
    end

    unless ctx.null?
      tok = ctx.as(Tokenizer)
      tok.state.on_token(Token.new(tok, token))
    end

    token
  end

  getter state, tkz

  def initialize(@state : Tokenizer::State, @skip_whitespace_tokens = false)
    @finalized = false
    @tkz = Myhtml::Lib.html_tokenizer_create
    res = Myhtml::Lib.html_tokenizer_init(@tkz)
    unless res == Myhtml::Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("Failed to html_tokenizer_init: #{res}")
    end

    Myhtml::Lib.html_tokenizer_tag_heap_set(@tkz, HEAP)

    Myhtml::Lib.html_tokenizer_opt_set(@tkz, Myhtml::Lib::HtmlTokenizerOptT::LXB_HTML_TOKENIZER_OPT_WO_COPY)
    Myhtml::Lib.html_tokenizer_callback_token_done_set(@tkz, @skip_whitespace_tokens ? CALLBACK_WO_WHITESPACE_TOKENS : CALLBACK, self.as(Void*))
  end

  def parse(str : String)
    parse str.to_slice
  end

  def parse(slice : Slice)
    @state.on_begin(self)

    res = Myhtml::Lib.html_tokenizer_begin(@tkz)
    unless res == Myhtml::Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to prepare tokenizer object for parsing: #{res}")
    end

    res = Myhtml::Lib.html_tokenizer_chunk(@tkz, slice.to_unsafe, slice.bytesize)
    unless res == Myhtml::Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to parse the html data: #{res}")
    end

    res = Myhtml::Lib.html_tokenizer_end(@tkz)
    unless res == Myhtml::Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to ending of parsing the html data: #{res}")
    end

    @state.on_end

    self
  end

  def finalize
    free
  end

  def free
    unless @finalized
      @finalized = true
      Myhtml::Lib.html_tokenizer_destroy(@tkz)
    end
  end
end

require "./tokenizer/*"
