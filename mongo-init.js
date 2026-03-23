# MongoDB Initialization Script
# This script runs automatically when the container starts for the first time

db = db.getSiblingDB('taskdb');

db.createCollection('users');
db.createCollection('tasks');

db.users.createIndex({ email: 1 }, { unique: true });
db.tasks.createIndex({ userId: 1 });

print('Database taskdb initialized successfully');
