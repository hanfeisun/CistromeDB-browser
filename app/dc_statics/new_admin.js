/**
 * Created by hanfei on 4/9/14.
 */
(function ($) {
    $(document).ready(function ($) {
        var refresh_button = $('<a href="./refresh" class="btn btn-warning"> <i class="icon-refresh icon-white"></i>&nbsp; Refresh </a>');
        $(".object-tools").prepend(refresh_button);
    });
})(django.jQuery);