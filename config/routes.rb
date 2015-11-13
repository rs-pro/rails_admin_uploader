RailsAdminUploader::Engine.routes.draw do
  resources :attachments, only: [:index, :create, :update, :destroy] do
    collection do
      post :sort
    end
  end
end

