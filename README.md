# Cornucopia

This is a gem with a bunch of tools which I think are useful when testing.  There are many parts to the gem and not
all parts are useful in all projects.  The gem is designed to work so that you can only use the parts that you need.
If the gem ever grows large enough or complex enough, I might break it into pieces similar to rspec.  For now,
this is just the way it is.

## Installation

Add this line to your application's Gemfile:

    gem 'cornucopia'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cornucopia

## Usage

### Hooks

The primary usefulness of the system is the built in integration system.  Using your favorite supported test system
include the appropriate files.

#### RSPEC:

spec_helper.rb or rails_helper.rb depending on the version of RSpec you are using, or where you want to put it:

```
require "cornucopia/rspec_hooks"
```

#### Cucumber:

env.rb:

```
require "cornucopia/cucumber_hooks"
```

#### Spinach:

env.rb:

```
require "cornucopia/spinach_hooks"
```

Once required in the hooks are installed, the system will automatically generate a report detailing the error.  The
automatic report includes information about the failure including:

* The exception
* The callstack
* Any instance variables for the test
* Details about the failed test and/or step
* Any Capybara windows and their details including a screen shot

### Capybara

I have added the following functions to Capybara to help simplify using it.

* synchronize_test(seconds=Capybara.default_wait_time, options = {}, &block)

This function yields to a block until the Capybara timeout occurs or the block returns true.

    # Wait until either #some_element or #another_element exists.
    Capybara::current_session.synchronize_test do
      page.all("#some_element").length > 0 ||
          page.all("#another_element").length > 0
    end

* **select_value**

This function selects the option from a select box based on the value for the selected option instead of the
value string.

    page.find("#state_selector").select_value(my_address.state_abbreviation)

* **value_text**

This function returns the string value of the currently selected option(s).

    page.find("#state_selector").value_text  # returns "Arizona" instead of "AZ"

### SitePrism

I love using SitePrism.  Unfortunately, I find it involves a lot of copy/paste.  To simplify the use of SitePrism, I
have created what are basically some macros:

* **patterned_elements(pattern, *element, options = {})**

This allows you to define a list of multiple elements where the pattern for the finder includes the text for what you
want the call the element.

You can specify the type of finder to be used with the _finder_type_ parameter, and if necessary include additional
parameters as well.

Examples:

    class MySection < SitePrism::Section
      patterned_elements "td.column_%{element_name}",
                         :my_element_1,
                         :my_element_2,
                         :my_element_3

      # instead of:
      # element :my_element_1, "td.column_my_element_1"
      # element :my_element_2, "td.column_my_element_2"
      # element :my_element_3, "td.column_my_element_3"

      patterned_elements "//td[name = \"${element_name}\"]",
                         :my_element_1,
                         :my_element_2,
                         :my_element_3,
                         finder_type: :xpath,
                         visible: false

      # instead of:
      # element :my_element_1, :xpath, "//td[name = \"my_element_1\"]", visible: false
      # element :my_element_2, :xpath, "//td[name = \"my_element_2\"]", visible: false
      # element :my_element_3, :xpath, "//td[name = \"my_element_3\"]", visible: false
    end

* **form_elements(form_type, *elements)**

This provides a quick and easy way to define elements for the items in forms.  The ids of the elements in a form
follow the simple pattern of:  &lt;form_name&gt;&lt;element_id&gt;.  Most of the time, you want the name of the
element to match the &lt;element_id&gt;.

Example:

    = form_for my_table_object do |form|
      = form.select :field_1
      = form.text_box :field_2
      = form.check_box :field_3

    class MySection < SitePrism::Section
      form_elements :my_table,
                    :field_1,
                    :field_2,
                    :field_3,

      # instead of:
      # element :field_1, "#my_table_field_1"
      # element :field_2, "#my_table_field_2"
      # element :field_3, "#my_table_field_3"
    end

* **id_elements(*elements)**

This is a quick and easy way to define elements where the name of the element is the same as the id for the element.

Example:

    class MySection < SitePrism::Section
      id_elements :my_item_1,
                  :my_item_2,
                  :my_item_3

      # instead of:
      # element :my_item_1, "#my_item_1"
      # element :my_item_2, "#my_item_2"
      # element :my_item_3, "#my_item_3"
    end

* **class_elements(*elements)**

This is a quick and easy way to define elements where the name of the element is the same as the class name used to
identify the element.

Example:

    class MySection < SitePrism::Section
      id_elements :my_item_1,
                  :my_item_2,
                  :my_item_3,
                  "my-class-name"

      # instead of:
      # element :my_item_1, ".my_item_1"
      # element :my_item_2, ".my_item_2"
      # element :my_item_3, ".my_item_3"
      # element :my_class_name, ".my-class-name"
    end

* **indexed_elements(pattern, *element, options = {})**

This allows you to define a list of multiple elements where the pattern for the finder is based on an index value.
This is useful for things like table columns.

You can specify the type of finder to be used with the _finder_type_ parameter, and if necessary include additional
parameters as well with _additional_options_.

Examples:

    class MySection < SitePrism::Section
      patterned_elements "td:nth-child(%{element_index})",
                         :my_element_1,
                         :my_element_2,
                         :my_element_3

      # instead of:
      # element :my_element_1, "td:nth-child(1)"
      # element :my_element_2, "td:nth-child(2)"
      # element :my_element_3, "td:nth-child(3)"

      patterned_elements "//td_%{element_index}",
                         :my_element_1,
                         :my_element_2,
                         :my_element_3,
                         finder_type: :xpath,
                         additional_options: { visible: false },
                         start_index: 3,
                         increment: 12

      # instead of:
      # element :my_element_1, :xpath, "//td_3", visible: false
      # element :my_element_2, :xpath, "//td_15", visible: false
      # element :my_element_3, :xpath, "//td_27", visible: false
    end

* **PageApplication**

SitePrism recommends memoizing the page objects.  I found it annoying to create a class for the pages and define a
new function for each page.  To simplify my life, I created the PageApplication class.  It will memoize pages for me
automatically as long as I follow some simple rules.

Basically, just create all of my pages underneath a single module in a single folder, and the a class derived from
PageApplication will find the pages and memoize them for you automatically.

    class MyApplication < Cornucopia::SitePrism::PageApplication
      def pages_module
        MyPagesModule
      end
    end

    module MyPagesModule
      module MyModule
        class MyPage < SitePrism::Page
          # your SitePirsm page definition here...
        end
      end
    end

    module MyPagesModule
      class MyOtherPage < SitePrism::Page
        # your SitePirsm page definition here...
      end
    end

    a_memoized_page       = MyApplication.my_module__my_page
    a_memoized_other_page = MyApplication.my_other_page

### Utilities

#### Configuration

    Cornucopia::Util::Configuration

The configuration class contains the various configurations that are used by the system.

* **seed**

    The seed value represents the seed value for `rand`.  It is used by the testing hooks to allow tests with
    randomized values to still be repeatable.  This value can be set or read.

* **order_seed**

    **Experimental** The order_seed value represents the seed value for the order that RSpec tests are run in if they 
    are run randomly.  This value in the configurations actually doesn't always work as it is very dependent on when 
    it is set during the RSpec configuration process.  The system tries, but it may be best just to do what this does
     and set `RSpec.configuration.seed = <your value>` youself in spec_helper.rb.  Really I've just started playing 
     around with it and seeing what I can do with it.

* **grab_logs**

    Indicates if the `Cornucopia::Util::LogCapture` class will capture any log files or not.

* **user_log_files**

    Returns a list of the log files which will be captures.  Changing the returned value will not affect log
    capturing settings.

* **num_lines(log_file_name=nil)**

    This gets the number of lines that are captured for the indicated log file.  If no value is passed in for
    `log_file_name`, the default number of lines will be returned.

* **default_num_lines=**

    Set the default number of lines to be captured when capturing log files.

* **add_log_file(log_file_name, options = {})**

    Add a log file to be captured.  The log path needs to be relative to the `Rails` log folder,
    or if Rails is not being used in the project, relative to the current working directory.  If a file is added
    multiple times, the file will be captured only once.  Subsequent calls will update the options for the file.

    Options:

    *num_lines* - The number of lines to capture for the file.

* **remove_log_file**

    Removes a log file from the list of files to be captured.

* **report_configuration(report_name)**

    Returns the `Cornucopia::Util::ConfiguredReport` for different reports.

    Supported Reports:

    *rspec*

    *cucumber*

    *spinach*

    *capybara_page_diagnostics*

* **print_timeout_min**

    This is the amount of time (in seconds) the will be allowed for the rendering of a variable when printing a
    value using `Cornucopia::Util::ReportBuilder.pretty_object`.

    This value exists because in real testing I found a few vaules (which I now exclude automatically) which took
    literally hours to print out using `pretty_inspect`.  (I suspect an infinite loop.)  This value prevents that by
    interrupting a printout which takes too long.

* **auto_open_report_after_generation**

    This allows you to tell the system to open a report with errors in it after the report is closed/finished.  If 
    you do not specify a type of report the value you specify will be the default value used for any report that is 
    generated. 

* And more...

    There are more configurations.  They are commented in the configuraiton.rb file.  If I didn't include them here, 
    then I probably thought that they were well commented in the file, or that they weren't important enough to put 
    here, or that they shouldn't be used normally, or (hopefully not) I just forgot to update the readme.

    If I forgot one and you think it should be here, let me know.

#### ConfiguredReport

The `Cornucopia::Util::ConfiguredReport` class allows you to configure what information is exported to generated
report files.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Todos...

SitePrism override section, element, sections and elements command to allow parameters to be passed in as additional 
    options.
  functions to override:
    main function (name)
    has_
    ???
  Already done only if original definition doesn't have options
Make configuration a singleton
ReportBuilder - reformat and styling of report?