version: 0.2
phases:
  install: 
    runtime-versions:
      docker: 18
    commands:       
      - PROJ_NAME="$PROJECT_NAME"
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - login=$(aws ecr get-login --no-include-email --region=us-east-1)
      - echo $login | bash
      - TAG="$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | head -c 8)"
      - REPOSITORY_URI="${ECR_ADDRESS}"
      - IMAGE_URI="${REPOSITORY_URI}:${TAG}"
  build:
    commands:
      - docker build -t "${IMAGE_URI}" .
      - docker tag "${IMAGE_URI}" "${IMAGE_URI}"
  post_build:
    commands:
      - docker push "${REPOSITORY_URI}:${TAG}"
      - printf '[{"name":"%s","imageUri":"%s"}]' "$PROJ_NAME" "$IMAGE_URI" > imagedefinitions.json
      - echo $CODEBUILD_RESOLVED_SOURCE_VERSION | head -c 8 > githash
artifacts:
  files: 
    - imagedefinitions.json
    - githash