require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  context "#new" do
		context "when not logged in" do
			should "redirect to the login page" do
				get :new
				assert_response :redirect
			end 
		end

		context "when logged in" do
			setup do
				sign_in users(:ro)
			end

			should "get the new page" do
				get :new
				assert_response :success
			end

			should "should set a flash error if the friend_id params is missing" do
				get :new, {}
				assert_equal "Friend required", flash[:error] 
			end

			should "display the friend's name" do
				get :new, friend_id: users(:ro1)
				assert_match /#{users(:ro1).full_name}/, response.body
			end

			should "assign a new user friendship" do
				get :new, friend_id: users(:ro1)
				assert assigns(:user_friendship)
			end


			should "assign a new user friendship to the correct friend" do
				get :new, friend_id: users(:ro1)
				assert_equal users(:ro1), assigns(:user_friendship).friend
			end

			should "assign a new user friendship to the currently logged in user" do
				get :new, friend_id: users(:ro1)
				assert_equal users(:ro), assigns(:user_friendship).user
			end

			should "return a 404 status if no friend is found" do
				get :new, friend_id: 'invalid'
				assert_response :not_found 
			end

			should "ask if you really want to friend the user" do
				get :new, friend_id: users(:ro1)
				assert_match /Do you really want to friend #{users(:ro1).full_name}/, response.body
			end
		end
	end

	context "#create" do
		context "when not logged in" do
			should "redirect to the login page" do
				get :new
				assert_response :redirect
				assert_redirected_to login_path
			end
		end

		context "when logged in" do
			setup do
				sign_in users(:ro)
			end

			context "with no friend_id" do
				setup do
					post :create
				end

				should "set the flash error message" do
					assert !flash[:error].empty?
				end

				should "redirect to the site root" do
					assert_redirected_to root_path
				end
			end

			context "with a valid friend id" do
				setup do
					post :create, user_friendship: {friend_id: users(:ro2)}
				end

				should "assign a friend object" do
					assert assigns(:friend)
					assert_equal users(:ro2), assigns(:friend)
				end

				should "assign a user_friendship object" do
					assert assigns(:user_friendship)
					assert_equal users(:ro), assigns(:user_friendship).user					
					assert_equal users(:ro2), assigns(:user_friendship).friend
				end

				should "create friendship" do
					assert users(:ro).friends.include?(users(:ro2))
				end

				should "redirect to profile page of the friend" do
					assert_response :redirect
					assert_redirected_to profile_path(users(:ro2))
				end

				should "set the flash success message" do
					assert flash[:success]
					assert_equal "You are now friends the #{users(:ro2).full_name}", flash[:success]
				end
			end
		end
	end
end