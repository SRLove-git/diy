import { ChatService } from './chat.service';

describe('ChatService.getMessages', () => {
  function buildService(andWhereCalls: string[]) {
    const fakeQb = {
      leftJoin: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn((cond: string) => {
        andWhereCalls.push(cond);
        return fakeQb;
      }),
      orderBy: jest.fn().mockReturnThis(),
      take: jest.fn().mockReturnThis(),
      getMany: jest.fn().mockResolvedValue([]),
    };
    const conversations = {
      findOneBy: jest.fn().mockResolvedValue({ id: 10, userAId: 32, userBId: 33 }),
    };
    const messages = { createQueryBuilder: jest.fn().mockReturnValue(fakeQb) };
    return new ChatService(
      conversations as any,
      messages as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
    );
  }

  it('删除过滤条件带括号，防止 OR 优先级绕过会话过滤', async () => {
    const andWhereCalls: string[] = [];
    const service = buildService(andWhereCalls);

    await service.getMessages(33, 10);

    // 不加括号会生成 (conversationId = ? AND ms.id IS NULL) OR deletedAt IS NULL，
    // 导致其他会话的消息也全部返回；必须为 OR 整体加括号。
    expect(andWhereCalls).toContain('(ms.id IS NULL OR ms.deletedAt IS NULL)');
    expect(andWhereCalls.some((c) => c.includes('deletedAt IS NULL') && !c.includes('('))).toBe(false);
  });
});
