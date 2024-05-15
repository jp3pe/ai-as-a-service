#!/bin/bash
. ./.env
. checkenv.sh

SERVICES=(resources frontend user-service)

function deploy () {
  for SERVICE in "${SERVICES[@]}"
  do
    echo ----------[ deploying $SERVICE ]----------
    cd $SERVICE
    if [ -f package.json ]; then
      npm install
      npm outdated
      npm update
    fi
    serverless deploy
    cd ..
  done
}

DOMAIN_SERVICES=(todo-service note-service schedule-service)
function domain () {
  for DOMAIN_SERVICE in "${DOMAIN_SERVICES[@]}"
  do
    echo ----------[ domain $DOMAIN_SERVICE ]----------
    cd $DOMAIN_SERVICE
    npm install
    serverless create_domain
    cd ..
  done
}

domain
deploy
. ./cognito.sh setup

SERVICES=(todo-service note-service schedule-service)
deploy
. ./bot/create.sh

cd frontend
npm run build
aws s3 sync dist/ s3://$CHAPTER4_BUCKET
cd ..

