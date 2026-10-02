pipeline {
    agent any
    environment {
        SONAR_SERVER = 'sonarqube-server'
        REPO_NAME = "${env.GIT_URL.split('/').last().split('\\.').first()}"
        DOCKER_REPO = 'alexsoft1988/lab.docker-jenkins'
        IMG_NAME    = 'aplicacion-python'
    }
    stages {
        stage('Checkout con python') {
            steps {
                checkout scm

                echo "Repositorio: ${env.REPO_NAME}"
                echo "Branch: ${env.BRANCH_NAME ?: 'N/A'}"
            }
        }

        
        stage('Ejecucion en Paralelo') {
                parallel {
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
                        

                }

        }
        
        stage('Build Imagen Docker') {
                            steps {

                                    sh 'docker build -t ${IMG_NAME} .'
                                    sh 'docker tag ${IMG_NAME} ${DOCKER_REPO}:${IMG_NAME}'

                                }
                        }

        stage('Docker Login') {
           steps {
               echo 'Iniciar en Docker'
               sh 'echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin docker.io'
               echo 'Login correcto'
           }
       }
         
        stage('Publicar Imagen Docker') {
        steps {
                withCredentials([usernamePassword(credentialsId: 'docker-token', passwordVariable: 'PSWD', usernameVariable: 'LOGIN')]) {
                    script {
                        sh 'echo ${PSWD} | docker login -u ${LOGIN} --password-stdin'
                        sh 'docker push ${DOCKER_REPO}:${IMG_NAME}'
                    }
                }
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
