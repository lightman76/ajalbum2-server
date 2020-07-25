Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'api/photo/search' => 'api/photo/photo#search'
  post 'api/photo/search' => 'api/photo/photo#search'
  get 'api/photo/date_outline_search' => 'api/photo/photo#date_outline_search'
  post 'api/photo/date_outline_search' => 'api/photo/photo#date_outline_search'


end
