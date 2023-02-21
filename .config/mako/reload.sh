#!/usr/bin/env sh

# '-i firefox' to test notification with an icon
makoctl reload
# to test 'high' urgency notificatoin add '-u critical '
notify-send -a "Notification test" -t 5000 "<summary line>" "Here is an example of how single (not grouped) notification will look with these theme colors"
# grouped
# notify-send -a "Grouped notification test" -t 5000 "<grouped summary line>" "Here is an example of how grouped notification will look with these theme colors"
# notify-send -a "Grouped notification test" -t 5000 "<grouped summary line>" "Here is an example of how grouped notification will look with these theme colors"
# notify-send -a "Grouped notification test" -t 5000 "<grouped summary line>" "Here is an example of how grouped notification will look with these theme colors"
