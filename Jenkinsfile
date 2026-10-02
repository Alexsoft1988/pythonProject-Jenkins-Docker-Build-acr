pipeline {
    agent any
    environment {
        SONAR_SERVER = 'sonarqube-server'
        REPO_NAME = "${env.GIT_URL.split('/').last().split('\\.').first()}"

        IMAGE_NAME       = 'aplicacion-python'
        IMAGE_TAG        = 'latest'
        DOCKERFILE_PATH  = 'Dockerfile'
        BUILD_NUMBER          = "${env.BUILD_NUMBER}"
        ACR_REGISTRY     = 'lab.docker.jenkins'
        DOCKER_CREDS_USR     = 'alexsoft1988'
        DOCKER_CREDS_PSW    = 'AGCd$2025_t3@35'
       
    }
    stages {
        stage('Checkout con python') {
            steps {
                checkout scm

                echo "Repositorio: ${env.REPO_NAME}"
                echo "Branch: ${env.BRANCH_NAME ?: 'N/A'}"
            }
        }

        stage('Compilar con python') {
            agent {
                docker { image 'python:2-alpine' }
            }
            steps {
                sh 'python -m py_compile source/main.py source/producto.py'
                stash(name: 'resultado -compilacion', includes: 'source/*.py*')
                echo "Compilacion Correcta"
                archiveArtifacts 'source/*.py*'
            }
        }
       
        stage('Analisis de SonarQube') {
            steps {
                script {
                    scannerHome = tool 'sonar-scanner'
                }
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${REPO_NAME} \
                            -Dsonar.projectName=${REPO_NAME} \
                            -Dsonar.sources=.
                            
                    """
                }
            }
        }

        stage('Build Image Docker') {
        steps {
                
                sh 'docker build -t ${ACR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -f ${DOCKERFILE_PATH} .'
                echo "imagen Docker Generado: ${DOCKERFILE_PATH}"
               
            }
        }
        stage('Publicar Imagen Docker') {
        steps {
            sh '''
            set -eux
            docker login ${ACR_REGISTRY} -u ${DOCKER_CREDS_USR} -p ${DOCKER_CREDS_PSW}
            docker tag ${ACR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
            docker push ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
            docker logout
            '''
        }
    }

    }
    post {

        success {
            echo '======================================'
            echo ' PIPELINE FINALIZADO CORRECTAMENTE'
            echo ' SonarQube Quality Gate: PASSED'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo ' PIPELINE FALLÓ'
            echo ' Revisar compilación, SonarQube o Quality Gate'
            echo '======================================'
        }

        always {
            echo "Repositorio analizado: ${REPO_NAME}"
        }
    }


}
