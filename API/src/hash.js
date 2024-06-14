import bcrypt from 'bcryptjs';

async function hashString(string) {
  const saltRounds = 10;
  try {
    const hash = await bcrypt.hash(string, saltRounds);
    return hash;
  } catch (error) {
    console.error('Error hashing string:', error);
    return null;
  }
}

if (process.argv.length < 3) {
    console.log('Usage: node hash.js <string_to_hash>');
  } else {
    const stringToHash = process.argv[2];
    console.log(await hashString(stringToHash));
  }
