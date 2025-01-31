import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that team member management works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const member1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pulse-sync', 'add-team-member', [
        types.principal(member1.address)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
  },
});

Clarinet.test({
  name: "Test recurring meeting scheduling functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const organizer = accounts.get('wallet_1')!;
    const attendee = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pulse-sync', 'add-team-member', [
        types.principal(organizer.address)
      ], deployer.address),
      
      Tx.contractCall('pulse-sync', 'schedule-meeting', [
        types.ascii("Weekly Team Sync"),
        types.uint(1000),
        types.uint(1100),
        types.list([types.principal(attendee.address)]),
        types.some({
          frequency: types.ascii("weekly"),
          interval: types.uint(1),
          end-date: types.uint(1672531200)
        }),
        types.list([types.uint(900), types.uint(930)])
      ], organizer.address)
    ]);
    
    block.receipts.forEach(receipt => {
      receipt.result.expectOk();
    });
    
    // Verify meeting details
    let meetingBlock = chain.mineBlock([
      Tx.contractCall('pulse-sync', 'get-meeting-details', [
        types.uint(1)
      ], deployer.address)
    ]);
    
    const meeting = meetingBlock.receipts[0].result.expectSome();
    assertEquals(meeting['recurrence'].frequency, types.ascii("weekly"));
  },
});
