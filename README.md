# leftright style views for Assert

This is an assert view based on the the [leftright gem](https://github.com/jordi/leftright).  For use with [Assert](https://github.com/teaminsight/assert) ~>0.8.

## View

This view groups results by either the test file or context class.  Groupings are shown in a left column with result details shown in a right column.

## Installation

The easiest way to install is to clone this repo into your `~/.assert/views` dir:

```sh
cd ~/.assert/views
git clone git://github.com/kellyredding/assert-view-leftright.git
```

See the Assert README for details on using 3rd party assert views.  https://github.com/teaminsight/assert#using-3rd-party-views

# Usage

If the view package has been installed to the user assert views dir as shown above, require it in your options file and set it as the view:

```ruby
# in ~/.assert/options.rb

Assert::View.require_user_view  'assert-view-leftright'
Assert.options.view             Assert::View::LeftrightView.new($stdout)
```

That's about it.  Run your assert test suite and see the new view in action.

### Options

This view sets a few default options:

* `right_column_width`: the max size of the right column, default: `80`
* `left_column_groupby`: what to group results by, default: `:context`
* `left_column_justify`: how to justify grouping labels in left col, default: `:right`

You can override these defaults in your assert user options file:

```ruby
# in ~/.assert/options.rb

# set the view
Assert::View.require_user_view 'assert-view-leftright'
Assert.options.view            Assert::View::LeftrightView.new($stdout)

# override the default options
Assert.view.options.left_column_groupby  :file
Assert.view.options.left_column_justify  :left
Assert.view.options.right_column_width   120
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
