pipeline {
    agent any 
    
    stages {
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
    }
}
