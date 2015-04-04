last_scroll_top = null;

function show_sub_report (event_obj)
{
  if (!(event_obj.shiftKey || event_obj.ctrlKey || event_obj.metaKey || event_obj.altKey))
  {
    link_item = $ (event_obj.target);
    $ ("#report-display-document").attr ("src", link_item.attr ("href"));
    event_obj.preventDefault ();
  }
}

function resize_list (event_obj)
{
  var max_height = window.innerHeight - 15;
  $ (".coruncopia-report-holder-list-holder").css ("max-height", max_height + "px");
  $ ("#report-display-document").css ("max-height", max_height + "px");
}

$ (document).ready (function ()
    {
      $ (document).on ("click", "a.coruncopia-report-link", {}, show_sub_report);
      $ (window).bind ("resize", {}, resize_list);
      resize_list (null);
    }
);