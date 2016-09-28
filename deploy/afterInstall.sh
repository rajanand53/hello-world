#composer create-project --prefer-dist laravel/laravel blog
# PATH_MIGRATED=/home/devuser/projects/aerod-backend-migrated
# cp $PATH_MIGRATED/.env.staging $PATH_MIGRATED/.env
# chmod -R 777 $PATH_MIGRATED/bootstrap/cache $PATH_MIGRATED/storage/logs
# sudo composer install -d $PATH_MIGRATED
su -c "composer create-project --prefer-dist laravel/laravel blog" -s /bin/bash devuser