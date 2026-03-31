pipeline {
    agent any

    environment {
        IMAGE_NAME = "nodejs.app1"
        CONTAINER_NAME = "nodejs-app-container"
        APP_PORT = "3000"
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo 'Cloning repo from GitHub...'
                git branch: 'main',
                    url: 'https://github.com/lvarshitha7/devops_git.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm install'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Stop Old Container') {
            steps {
                echo 'Stopping old container if running...'
                sh '''
                    # Stop and remove container by name
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # Kill any other container using port 3000
                    CONTAINER=$(docker ps -q --filter "publish=${APP_PORT}")
                    if [ ! -z "$CONTAINER" ]; then
                        echo "Found container using port ${APP_PORT}, stopping it..."
                        docker stop $CONTAINER || true
                        docker rm $CONTAINER || true
                    fi

                    # Wait 2 seconds for port to be released
                    sleep 2
                '''
            }
        }

    stage('Run New Container') {
            steps {
                echo 'Starting new container...'
                sh '''
                    docker run -d \
                        -p ${APP_PORT}:${APP_PORT} \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Verify App Running') {
            steps {
                echo 'Verifying container is running...'
                sh '''
                    # Wait for app to start
                    sleep 3

                    # Check container is running
                    docker ps | grep ${CONTAINER_NAME}

                    # Check app responds
                    curl -f http://localhost:${APP_PORT} || echo "App may still be starting..."

                    # Show container logs
                    echo "---- Container Logs ----"
                    docker logs ${CONTAINER_NAME}
                '''
            }
        }

        stage('Cleanup Old Images') {
            steps {
                echo 'Removing dangling/unused Docker images...'
                sh '''
                    docker image prune -f || true
                '''
            }
        }
    }

    post {
        success {
            echo ' ========================================='
            echo ' BUILD AND DEPLOY SUCCESSFUL!'
            echo ' ========================================='
            echo " App is running at http://<YOUR_EC2_IP>:${APP_PORT}"
        }
        failure {
            echo '========================================'
            echo ' BUILD FAILED - Check console output!'
            echo ' ========================================='
            sh '''
                echo "---- Docker PS ----"
                docker ps -a || true
                echo "---- Container Logs ----"
                docker logs ${CONTAINER_NAME} || true
            '''
        }
        //always {
            //echo 'Pipeline finished.'
            //sh '''
              //  echo "---- Running Containers ----"
                //docker ps
            //'''
        //}
    }
}
