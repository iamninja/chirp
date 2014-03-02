require 'test_helper'
class UserTest < ActiveSupport::TestCase
# test "the truth" do
# assert true
# end

	should have_many :user_friendships
	should have_many :friends
	should have_many(:pending_user_friendships)
	should have_many(:pending_friends)
	should have_many(:requested_user_friendships)
	should have_many(:requested_friends)
	should have_many(:blocked_user_friendships)
	should have_many(:blocked_friends)
	should have_many(:activities)

	test "a user should enter a first name" do
		user = User.new
		assert !user.save
		assert !user.errors[:first_name].empty?
	end
	test "a user should enter a last name" do
		user = User.new
		assert !user.save
		assert !user.errors[:last_name].empty?
	end
	test "a user should enter a profile name" do
		user = User.new
		assert !user.save
		assert !user.errors[:profile_name].empty?
	end
	test "a user should have a unique profile name" do
		user = User.new
		user.profile_name = users(:ro).profile_name

		assert !user.save
		assert !user.errors[:profile_name].empty?
	end
	test "a user should have a profile name without spaces" do
		user = User.new
		user.profile_name = "My Profile With Spaces"
		assert !user.save
		assert !user.errors[:profile_name].empty?
		assert user.errors[:profile_name].include?(" must be formatted correctly.")
	end
	test "a user can have a correctly formatted profile name" do
		user = User.new( first_name: "Vagios", last_name:  "Vlachos", email: "vagios@vlachos.com")
		user.password = user.password_confirmation = "apasswordd"

		user.profile_name = "vagiosvlachos_1"
		assert user.valid?
	end
	test "that no error is raised when trying to access a friendlist" do
		assert_nothing_raised do
			users(:ro).friends
		end
	end
	test "that creating friendships for a user works" do
		users(:ro).pending_friends << users(:ro2)
		users(:ro).pending_friends.reload
		assert users(:ro).pending_friends.include?(users(:ro2))
	end

	should "that calling to_param on a user returns the profile_name" do
		assert_equal "robotron",users(:ro).to_param
	end

	context "#has_blocked?" do
		should "return true if a user has blocked another user" do
			assert users(:ro).has_blocked?(users(:blocked_friend))
		end

		should "return false if a user has not blocked another user" do
			assert !users(:ro).has_blocked?(users(:ro1))
		end
	end

	context "#create_activity" do
		should "increase the activity count with a status" do
			assert_difference "Activity.count" do
				users(:ro).create_activity(statuses(:one), "created")
			end
		end

		should "set the targetable instance to the status passed in" do
			activity = users(:ro).create_activity(statuses(:one),"created")
			assert_equal statuses(:one), activity.targetable
		end

		should "increase the activity count with an album" do
			assert_difference "Activity.count" do
				users(:ro).create_activity(albums(:best), "created")
			end
		end

		should "set the targetable instance to the album passed in" do
			activity = users(:ro).create_activity(albums(:best),"created")
			assert_equal albums(:best), activity.targetable
		end
	end

end