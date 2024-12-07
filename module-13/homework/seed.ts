(async () => {
  const { MongoClient } = require("mongodb");
  const fs = require("fs");
  const path = require("path");

  const uri = "mongodb://localhost:27017";

  const dbName = "nyc";
  const collectionName = "restaurants";

  const jsonFilePath = path.join(__dirname, "restaurants.json");
  const client = new MongoClient(uri);

  try {
    await client.connect();

    const db = client.db(dbName);
    const collection = db.collection(collectionName);

    const data = fs.readFileSync(jsonFilePath, 'utf8');
    const restaurants = JSON.parse(data);

    const result = await collection.insertMany(restaurants);
    console.log(`${result.insertedCount} documents were inserted.`);
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    await client.close();
  }
})()