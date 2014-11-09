# Cornucopia

This is a gem with a bunch of tools which I think are useful when testing.  There are many parts to the gem and not
all parts are useful in all projects.  The gem is designed to work so that you can only use the parts that you need.
If the gem ever grows large enough or complex enough, I might break it into pieces similar to rspec.  For now,
this is just the way it is.

## Installation

Add this line to your application's Gemfile:

    gem 'cornucopia', '~> 0.1.0', git: "git@github.com:RealNobody/cornucopia.git"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cornucopia

## Usage

### Utilities

#### Configuration

    Cornucopia::Util::Configuration

The configuration class contains the various configurations that are used by the system.

* **seed**

    The seed value represents the seed value for `rand`.  It is used by the testing hooks to allow tests with
    randomized values to still be repeatable.  This value can be set or read.

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

ReportBuilder - delayed reports
  @delayed_reports = { key: { report_name: "", report_table: ReportTable.new do || end} }
  finder diagnostics - within sub-report.  delayed_report?