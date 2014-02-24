require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  should belong_to(:user)
  should belong_to(:friend)

  test "that creating a friendship works without raising an exception" do
  	assert_nothing_raised do
  		UserFriendship.create user: users(:ro), friend: users(:ro1)
  	end
  end

  test "that creating a friendshipbased on user_id and friend_id works" do
  	UserFriendship.create user_id: users(:ro).id, friend_id: users(:ro1).id
  	assert users(:ro).friends.include?(users(:ro1))
  end
end
