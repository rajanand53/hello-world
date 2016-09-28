#composer create-project --prefer-dist laravel/laravel blog
# PATH_MIGRATED=/home/devuser/projects/aerod-backend-migrated
# cp $PATH_MIGRATED/.env.staging $PATH_MIGRATED/.env
# chmod -R 777 $PATH_MIGRATED/bootstrap/cache $PATH_MIGRATED/storage/logs
# sudo composer install -d $PATH_MIGRATED
su - devuser -c "composer create-project --prefer-dist laravel/laravel /home/devuser/projects/blog"
su - devuser -c "chmod -R 777 /home/devuser/projects/blog/bootstrap/cache /home/devuser/projects/blog/storage/logs"