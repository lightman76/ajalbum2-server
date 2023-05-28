Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'api/photo/search' => 'api/photo/photo#search'
  post 'api/photo/search' => 'api/photo/photo#search'
  get 'api/photo/date_outline_search' => 'api/photo/photo#date_outline_search'
  post 'api/photo/date_outline_search' => 'api/photo/photo#date_outline_search'

  put 'api/:user/photo' => 'api/photo/photo#update_photos'
  delete 'api/:user/photo/:photo_time_ids' => 'api/photo/photo#delete_photos'

  post 'api/tag/ids' => 'api/tag/tag#tags_by_id'
  post 'api/:user_name/tag' => 'api/tag/tag#create_tag'
  get 'api/:user_name/tags' => 'api/tag/tag#retrieve_all_tags'
  post 'api/:user_name/tags' => 'api/tag/tag#search_tags'

  post 'api/:user_name/authenticate' => 'api/user/user#authenticate'

end
