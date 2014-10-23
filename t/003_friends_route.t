use Test::More tests => 3;
use strict;
use warnings;

# the order is important
use MyTwitter::App;
use Dancer::Test;

route_exists [GET => '/friends'], 'a route handler is defined for /followers';
response_status_is ['GET' => '/friends'], 200, 'response status is 200 for /followers';
