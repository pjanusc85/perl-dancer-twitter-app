package MyTwitter::App;
use Dancer ':syntax';
use Dancer::Template::TemplateToolkit;
use Net::Twitter;
use Scalar::Util 'blessed';
use Data::Dumper;
use Array::Utils qw(:all);

our $VERSION = '0.1';

# API Keys
my $consumer_key = 'XXXXXXXXXXX';                                     # Twitter API Consumer Key
my $consumer_secret = 'XXXXXXXX';         # Twitter API Consumer Secret
my $token = 'XXXXXXXXX';                   # Twitter API Access token
my $token_secret = 'XXXXXXX';                 # Twitter API Access token secret

my $my_screen_name = 'nba';

my $tweet_count = 20;       # Default number of tweets to display
my $followers_count = 50;   # Default number of followers to display

# Initializing the Twitter API Connection via Net::Twitter
my $nt = Net::Twitter->new(
    traits   => [qw/API::RESTv1_1/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
    ssl                 => 1
);


# Gets the intersection between the people they follow with the specified two screen names
get '/:screen_name1/following/:screen_name2' => sub
{
    my @array1 = $nt->friends_ids( { screen_name => param('screen_name1') } )->{ids};   # Gets the list of IDs that screen_name1 is following
    my @array2 = $nt->friends_ids( { screen_name => param('screen_name2') } )->{ids};   # Gets the list of IDs that screen_name2 is following

    # intersection using Array::Utils
    my @isect = intersect(@{$array1[0]}, @{$array2[0]});
    my $users = $nt->lookup_users( { user_id => \@isect } );
    template 'friends' , { 'friends' => $users, 'display_text' => "Displaying common people being followed between ".param('screen_name1')." and ".param('screen_name2') };

};

# Gets the list of people being followed with the specified screen name
get '/:screen_name/following' => sub
{
    my $results = $nt->friends( { screen_name => param('screen_name') } ); # Gets the list of people that screen_name is following

    template 'friends' , { 'friends' => $results->{users}, 'display_text' => "Displaying friends of ".param('screen_name') };
};

# Gets the recent tweets with the specified screen name
get '/:screen_name/recent_tweets' => sub
{
    my $results = $nt->user_timeline( { screen_name => param('screen_name'), count => $tweet_count } ); # minimum of 20 tweets
    my $tweet_id;
    my $status;
    my @statuses;

    for my $result (@$results)
    {
        $tweet_id = $result->{id_str};
        $status = $nt->oembed( { id => $tweet_id } );   # Calling the oembed api to get the actual html of the tweet
        push(@statuses, $status->{html});
    }

    template 'index', { 'tweets' => \@statuses, 'tweet_count', $tweet_count };
};

# Defaults to Welcome text
get '/' => sub
{
    template 'welcome';
};

true;
