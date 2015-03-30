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

This function yields to a block until the Capybara timeout occurs or the block returns true.  I added it because I 
find that simple synchronized find functions are not always sufficient.  This will allow the system to wait till any 
random block returns true, synchronizing to a wide variety of conditions.

    # Wait until either #some_element or #another_element exists.
    Capybara::current_session.synchronize_test do
      page.all("#some_element").length > 0 ||
          page.all("#another_element").length > 0
    end

* **select_value**

This function selects the option from a select box based on the value for the selected option instead of the
value string.

If I have the a SELECT list with the following option:

    <option value="AZ">Arizona</option>

The following line will select the "Arizona" option:

    my_address.state_abbreviation = "AZ"
    page.find("#state_selector").select_value(my_address.state_abbreviation)

* **value_text**

This function returns the string value of the currently selected option(s).

    page.find("#state_selector").value_text  # returns "Arizona" instead of "AZ" if "AZ" is selected.

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

    class MyPageApplication < Cornucopia::SitePrism::PageApplication
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

    a_memoized_page       = MyPageApplication.my_module__my_page
    a_memoized_other_page = MyPageApplication.my_other_page

#### Capybara::Node::Simple integration

SitePrism is very useful, but it only works with the main page:  `Capybara::current_session.page`.  I have found that 
there are times where it is very useful to use the `Capybara::Node::Simple` object.  The problem I have is that I can't
use my SitePrism pages with the SimpleNode.

I therefore added a property `owner_node` to the `SitePrism::Page` and `SitePrism::Section` classes.  You can assign 
to this property the `Capybara::Node` that you want to execute the finder functions against.

An example might be something like:

    RSpec.describe MyController, type: :controller do
      get :index

      expect(response.status).to eq 200

      my_node = Capybara::Node::Simple.new(response.body)
      my_page = MyPageApplication.my_page

      my_page.owner_node = my_node

      expect(my_page.my_section.my_list[0].my_element.text).to eq(my_expectation)
    end

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

I've tried to create reasonable default configuration for what gets reported when there is an error in the test 
environments that I know enough to support:  Cucumber, RSpec, and Spinach.  I also provided a default configuration 
for what to report when an error occurs a Capybara page is open.

You can override these defaults if you find a need and specify the configured report that is used when an exception 
occurs in a particular environment.

The default configurations will output the following information that it can find/is available:

* The exception that caused the problem and its call stack
* Test details such as the test name, file path, etc.
* Any instance variables for the test
* Any values defined using `let`
* The log for the current environment
* Any additional log files specified by the user
* Any Capybara details that can be determined like the HTML source, a screen shot, etc.

The ConfiguredReport class and the example configurations detail how the configured reports work if you feel the need
to create your own. 

#### ReportBuilder

The ReportBuilder is the tool which is used to create the reports that are generated when an exception is caught.  
There are 3 basic objects to work with in a report:

##### Tests

A test is basically a new sub-report.  When you create a new test, you will pass in a name for the test.  This name 
will appear in the left portion of the report.  When the user clicks on the test, the report for the test will appear
on the right side.  You will likely not need to create your own tests.  To do so, you call `within_test`.

An example:

    Cornucopia::ReportBuilder.current_report.within_test("This is the name of my test") do
      # build your test report here.
    end

##### Sections

A section is a block within a test.  The section has a header that describes the section and is the primary container
for tables.  Multiple sections are allowed within a test and are colored alternating colors to distinguish them.

An example:

    Cornucopia::ReportBuilder.current_report.within_section("Section header") do |section|
      # Build the details for the section here.
      
      # NOTE:  Currently section is == Cornucopia::ReportBuilder.current_report  This may or may not be so in the 
      #        future.
    end

Note that only one test is allowed to be active at all times and that if no other test is active a defaut "unknown" 
test will be used.  As a result, you can call the `within_section` function directly from the report object and it 
will be within the currently active test.

##### Tables

A table is exactly what it sounds like it is a table of information.  Tables have rows of information pairs - a label
and the information to be shown.  Unlike Sections and Tests, Tables can be nested inside each other.  That is the 
information in a table row can be another table.

If the information for a particular cell is too large, that information will be partially hidden from view so that 
the table size doesn't get out of hand.

To write out a value, you simply use `write_stats` and pass in a label and a value.

An example:

    Cornucopia::ReportBuilder.current_report.within_section("Section header") do |section|
      section.within_table do |table|
        table.write_stats "Statistic name", "Statistic value"

        ReportTable.new nested_table: table, nested_table_label: "Sub Table" do |sub_table|
          sub_table.write_stats "Sub statistic name", "Sub statistic value"
        end
      end
    end

Tables have a lot of options:

* **table_prefix** - This is the value to use to "open" the table.
* **table_postfix** - This is the value to use to "close" the table.
* **report_table** - If set, all table calls are passed through to this table object.  The purpose of this value is 
to allow for an optional sub-table.  That is the code acts as if it is working on a sub-table, but in reality it is 
working in the report_table.
* **nested_table** - This is the table that the table being created will be a sub-table of.  When the new table is 
completed, it till be output into a row of the specified table.
* **nested_table_label** - This is the lable that will be used for this table when it is output in the nested_table.
* **nested_table_options** - A hash of options that will be used to determine the look and feel of the nested table 
when it is output.  These options are passed into write_stats when the table is output.
* **not_a_table** - If set, then when write_stats is called, the label value is ignored and the value is simply 
appended to the table as-is.
* **suppress_blank_table** - If set, the table will not be output if it is blank.



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Todos...

ReportBuilder - reformat and styling of report?