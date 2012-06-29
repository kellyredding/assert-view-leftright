require 'assert/view/base'

module Assert::View

  class LeftrightView < Base

    require 'assert/view/helpers/capture_output'
    include Helpers::CaptureOutput

    require 'assert/view/helpers/ansi_styles'
    include Helpers::AnsiStyles

    options do
      styled         true
      pass_styles    :green
      fail_styles    :red, :bold
      error_styles   :yellow, :bold
      skip_styles    :cyan
      ignore_styles  :cyan

      default_right_column_width    80
      default_left_column_groupby   :context
      default_left_column_justify   :right
    end

    def after_load
      puts "Loaded suite (#{test_count_statement})"
    end

    def on_start
      if tests?
        puts "Running tests in random order, seeded with \"#{runner_seed}\""
      end
    end

    def on_finish
      if tests?
        puts
        leftright_groups.each do |grp|
          detailed_results = matched_result_details_for(grp, suite.ordered_tests)

          result_abbrevs = ""
          result_details = []

          detailed_results.each do |details|
            result = details.result
            result_abbrev = options.send("#{result.to_sym}_abbrev")

            result_abbrevs << ansi_styled_msg(result_abbrev, result_ansi_styles(result))

            if show_result_details?(result)
              detail_s = [
                ansi_styled_msg(result.to_s, result_ansi_styles(result)),
                captured_output(details.output),
                "\n"
              ].compact.join("\n")

              result_details << detail_s
            end
          end

          left_column(left_column_display(grp))
          right_column(result_abbrevs, {
            :width => (options.styled ? 10 : 1)*right_column_width
          })

          if result_details.size > 0
            left_column("")
            right_column(result_details.join, {:endline => true})
          end
        end
      end

      # same as `Assert::View::DefaultView`

      styled_results_sentence = results_summary_sentence do |summary, sym|
        # style the summaries of each result set
        ansi_styled_msg(summary, result_ansi_styles(sym))
      end

      puts
      puts "#{result_count_statement}: #{styled_results_sentence}"
      puts
      puts "(#{run_time} seconds)"
    end

    protected

    def leftright_groups
      case self.options.left_column_groupby
      when :context
        self.ordered_suite_contexts
      when :file
        self.ordered_suite_files
      else
        []
      end
    end

    def left_column_display(leftcol_value)
      case self.options.left_column_groupby
      when :context
        leftcol_value.to_s.gsub(/Test\Z/, '').gsub(/Tests\Z/, '')
      when :file
        leftcol_value.to_s.gsub(Dir.pwd, '').gsub(/^\/+test\//, '')
      else
        leftcol_value.to_s
      end
    end

    def left_column_width
      @left_col_width ||= case self.options.left_column_groupby
      when :context
        self.suite_contexts.collect{|f| f.to_s.gsub(/Test\Z/, '').gsub(/Tests\Z/, '')}
      when :file
        self.suite_files.collect{|f| f.to_s.gsub(File.expand_path(".", Dir.pwd), '').gsub(/^\/+test\//, '')}
      else
        []
      end.inject(0) do |max_size, klass|
        klass.to_s.size > max_size ? klass.to_s.size : max_size
      end + 1
    end

    def left_column(text, opts={})
      col_width = opts[:width] || left_column_width
      out = case options.left_column_justify
      when :left
        text.to_s+" "*(col_width-(text.to_s.size))
      else
        " "*(col_width-(text.to_s.size))+text.to_s+" "
      end
      print out
    end

    def right_column(text, opts={})
      lines = text.split("\n")
      right_columnize(lines.first || "", opts)
      (lines[1..-1] || []).each do |line|
        left_column("")
        right_columnize(line, opts)
      end
      puts if opts[:endline]
    end

    def right_column_width
      options.right_column_width
    end

    def right_columnize(text, opts={})
      col_width = opts[:width] || right_column_width

      # split text into array of limit sizes
      n,r = text.empty? ? [1,0] : text.size.divmod(col_width)
      grps = (0..(n-1)).collect do |i|
        i == 0 ? text[i*col_width,col_width] : " "+text[i*col_width,col_width]
      end
      if r > 0
        grps << (n > 0 ? " "+text[-r,r] : text[-r,r])
      end

      puts grps.first
      if grps.size > 1
        grps[1..-1].each do |g|
          self.left_column("")
          puts g
        end
      end
    end

  end

end
